open Graphql
open GraphqlCodegen
open AST

exception Unknown_type(string)
exception Missing_fragment(string)
exception Non_input_type(string)
exception Empty_fragment(string)
exception Empty_inline_fragment
exception Invalid_type_condition(string)

module type Container = {
  type t
}

module WithGqlWrappers = (Base: Container) => {
  type base = Base.t
  type rec t =
    | Base(Base.t)
    | List(t)
    | NonNull(t_nn)
  and t_nn =
    | Base_nn(Base.t)
    | List_nn(t)
}

module BaseInput = {
  type t =
    | Scalar(string)
    | Enum(string)
    | Object(string)
}

module InputType = WithGqlWrappers(BaseInput)

module BaseUnresolvedOutput = {
  type selectionSet = {
    type_: TypeNode.t,
    fields: Dict.t<array<SelectionSetNode.t>>,
  }
  type union = {
    base?: selectionSet,
    members: Dict.t<selectionSet>,
  }
  type t =
    | SelectionSet(selectionSet)
    | Union(union)
}

module UnresolvedOutputType = {
  include WithGqlWrappers(BaseUnresolvedOutput)
  /*
  let combineSelectionSetFields = (
    fields1: array<SelectionSetNode.t>, 
    fields2: array<SelectionSetNode.t>
  ) => 
    Array.concat(fields1, fields2)
          ->Array.groupBy(f => f.name)
          ->Dict.valuesToArray
          ->Array.map(
            (({name, selectionSets: ?fst}, vs)) =>  {
              let selectionSets =
                Array.reduce(vs, fst, (acc, {selectionSets: ?ss}) =>
                  switch (acc, ss) {
                    | (Some(a1), Some(a2)) => Some(Array.concat(a1, a2))
                    | (Some(a), _) => Some(a)
                    | (_, ma) => ma
                  })
              {BaseUnresolvedOutput.name, selectionSets: ?selectionSets}
            })
 */

  let combineLikeSelectionSets = (
    {type_, fields: f1}: BaseUnresolvedOutput.selectionSet,
    {fields: f2}: BaseUnresolvedOutput.selectionSet,
  ) => {
    BaseUnresolvedOutput.type_,
    fields: Dict.mergeWith(f1, f2, Array.concat),
    //combineSelectionSetFields(f1, f2)
  }

  let mergeSelectionSets = (
    (init, selects): Array.nonEmpty<BaseUnresolvedOutput.selectionSet>,
  ): BaseUnresolvedOutput.selectionSet =>
    Array.reduce(selects, init, ({type_, fields: acc}, {fields: new}) => {
      type_,
      fields: Dict.mergeWith(acc, new, Array.concat),
    })

  let combineUnions = (u1: BaseUnresolvedOutput.union, u2: BaseUnresolvedOutput.union) => {
    BaseUnresolvedOutput.base: ?Option.liftConcat(combineLikeSelectionSets, u1.base, u2.base),
    members: Dict.mergeWith(u1.members, u2.members, combineLikeSelectionSets),
  }

  let mergeUnions = (
    (init, unions): Array.nonEmpty<BaseUnresolvedOutput.union>,
  ): BaseUnresolvedOutput.union => Array.reduce(unions, init, combineUnions)

  let mergeLike = (t1: base, t2: base): base =>
    switch (t1, t2) {
    | (SelectionSet(ss1), SelectionSet(ss2)) => SelectionSet(combineLikeSelectionSets(ss1, ss2))
    | (Union(u1), Union(u2)) => Union(combineUnions(u1, u2))
    | (SelectionSet(ss), Union({?base, members}))
    | (Union({?base, members}), SelectionSet(ss)) =>
      Union({
        base: ?Option.liftConcat(combineLikeSelectionSets, base, Some(ss)),
        members,
      })
    }

  let combineLike = ((t, ts): Array.nonEmpty<base>): base => Array.reduce(ts, t, mergeLike)
}

type t =
  | PrintString(string)
  | PrintType({name: string, type_: UnresolvedOutputType.t})
  | PrintVariable({name: string, type_: InputType.t})
  | PrintDefinition(ExecutableDefinitionNode.t)

let fromDefinitions = definitions =>
  Array.toReversed(definitions)
  ->Array.map(d => PrintDefinition(d))
  ->List.fromArray

let process = (t, fragments: Dict.t<FragmentDefinitionNode.t>, schema) => {
  let extractInputType = (typeNode: TypeNode.t): InputType.t => {
    open Schema
    let rec named = (nameNode): InputType.base => {
      let name = NameNode.value(nameNode)
      switch getType(schema, name)->Option.map(Named.parse) {
      | None => raise(Unknown_type(name))
      | Some(Scalar(s)) => Scalar(Scalar.name(s))
      | Some(Enum(e)) => Enum(Enum.name(e))
      | Some(InputObject(io)) => Object(InputObject.name(io))
      | Some(Object(_))
      | Some(Interface(_))
      | Some(Union(_)) =>
        raise(Non_input_type(name))
      }
    }
    and base = (typeNode: TypeNode.t): InputType.t =>
      switch typeNode {
      | NamedType(n) => Base(named(n.name))
      | ListType({type_}) => List(base(type_))
      | NonNullType(nn) =>
        NonNull(
          switch nn.type_ {
          | NamedType(n) => Base_nn(named(n.name))
          | NullListType({type_}) => List_nn(base(type_))
          },
        )
      }
    base(typeNode)
  }

  let extractSelectionType = (
    baseType: Schema.ValidForTypeCondition.t,
    selections: array<SelectionSetNode.selectionNode>,
  ): UnresolvedOutputType.t => {
    let rec extractFields = (node: SelectionSetNode.selectionNode, type_: TypeNode.t) =>
      switch node {
      | Field({name, ?selectionSet}) =>
        BaseUnresolvedOutput.SelectionSet({
          type_,
          fields: Dict.fromArray([(AST.NameNode.value(name), Option.toArray(selectionSet))]),
        })
      | FragmentSpread(f) => {
          let fragmentName = NameNode.value(f.name)
          let fragment = Dict.get(fragments, fragmentName)
          switch fragment {
          | None => raise(Missing_fragment(fragmentName))
          | Some(f) => {
              let selections = f->FragmentDefinitionNode.selectionSet->SelectionSetNode.selections
              switch Array.headTail(selections) {
              | None => raise(Empty_fragment(fragmentName))
              | Some(s, ss) =>
                UnresolvedOutputType.combineLike((
                  extractFields(s, type_),
                  Array.map(ss, extractFields(_, type_)),
                ))
              }
            }
          }
        }
      | InlineFragment({typeCondition, selectionSet}) => {
          let typeName = NamedTypeNode.name(typeCondition)->NameNode.value
          let nestedType = switch Schema.getType(schema, typeName) {
          | None => raise(Unknown_type(typeName))
          | Some(t) => Schema.Named.parse(t)
          }
          let validatedType = switch Schema.ValidForTypeCondition.fromNamed(nestedType) {
          | None => raise(Invalid_type_condition(typeName))
          | Some(t) => t
          }
          Union({
            members: Dict.fromArray([
              (typeName, {BaseUnresolvedOutput.type_: validatedType, fields}),
            ]),
          })
        }
      | InlineFragment({selectionSet}) =>
        switch Array.headTail(selections) {
        | None => raise(Empty_inline_fragment)
        | Some(s, ss) =>
          UnresolvedOutputType.combineLike((
            extractFields(s, type_),
            Array.map(ss, extractFields(_, type_)),
          ))
        }
      }

    let arr = selections->Array.map(extractFields)
    arr
  }

  let processStep = (t): (list<t>, array<string>) =>
    switch t {
    | PrintString(str) => (list{}, [str])
    | PrintType(_) => (list{}, [])
    | PrintVariable(_) => (list{}, [])
    | PrintDefinition(definition) => {
        let (variableDefs, selectionSet) = switch definition {
        | OperationDefinition(o) => (o.variableDefinitions, o.selectionSet)
        | FragmentDefinition(f) => (f.variableDefinitions, f.selectionSet)
        }
        let variableSteps = Array.map(Option.getOr(variableDefs, []), a => {
          let name =
            a
            ->VariableDefinitionNode.variable
            ->VariableNode.name
            ->NameNode.value
          let type_ =
            a
            ->VariableDefinitionNode.type_
            ->extractInputType
          PrintVariable({name, type_})
        })
        let selectionSteps =
          selectionSet
          ->SelectionSetNode.selections
          ->Array.map(a => a)
        (Array.concat(variableSteps, [])->List.fromArray, [])
      }
    }
}
