open Graphql
open AST

exception Unknown_type(string)
exception Missing_fragment(string)
exception Non_input_type(string)
exception Empty_fragment(string)
exception Empty_inline_fragment
exception Invalid_inline_fragment(string)
exception Invalid_type_condition(string)
exception Selection_on_union(string)
exception Empty_definition(string)
exception Missing_base_type(operationTypeNode)
exception Unknown_field(string)
exception Composite_type_without_fields(string)
exception Simple_type_with_fields(string)
exception Invalid_type_name(array<string>)

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

module InputType = {
  include WithGqlWrappers(BaseInput)
  let traverse = (
    base: t,
    ~onScalar,
    ~onEnum,
    ~onObject,
    ~onList=t => t,
    ~onNull=t => t,
    ~onNonNull=t => t,
  ) => {
    let rec down = (t, wrappers) =>
      switch t {
      | Base(Scalar(s)) => (onScalar(s), list{onNull, ...wrappers})
      | Base(Enum(e)) => (onEnum(e), list{onNull, ...wrappers})
      | Base(Object(o)) => (onObject(o), list{onNull, ...wrappers})
      | List(l) => down(l, list{onList, onNull, ...wrappers})
      | NonNull(nn) =>
        switch nn {
        | Base_nn(Scalar(s)) => (onScalar(s), list{onNonNull, ...wrappers})
        | Base_nn(Enum(e)) => (onEnum(e), list{onNonNull, ...wrappers})
        | Base_nn(Object(o)) => (onObject(o), list{onNonNull, ...wrappers})
        | List_nn(l) => down(l, list{onList, onNonNull, ...wrappers})
        }
      }
    let rec up = ((v, wrappers)) =>
      switch wrappers {
      | list{} => v
      | list{fst, ...rst} => up((fst(v), rst))
      }
    up(down(base, list{}))
  }
}

module BaseUnresolvedOutput = {
  type selectionSet = {
    type_: Schema.ValidForField.t,
    fields: Dict.t<array<SelectionSetNode.t>>,
  }
  type union = {
    type_: Schema.Abstract.t,
    base?: selectionSet,
    members: Dict.t<selectionSet>,
  }
  type t =
    | SelectionSet(selectionSet)
    | Union(union)
}

module UnresolvedOutputType = {
  include WithGqlWrappers(BaseUnresolvedOutput)

  type result =
    | SingleFragment(string)
    | Combined(base)
  let combineSelectionSets = (
    {type_, fields: f1}: BaseUnresolvedOutput.selectionSet,
    {fields: f2}: BaseUnresolvedOutput.selectionSet,
  ) => {
    BaseUnresolvedOutput.type_,
    fields: Dict.mergeWith(f1, f2, Array.concat),
  }

  let mergeSelectionSets = (
    (init, selects): Array.nonEmpty<BaseUnresolvedOutput.selectionSet>,
  ): BaseUnresolvedOutput.selectionSet =>
    Array.reduce(selects, init, ({type_, fields: acc}, {fields: new}) => {
      type_,
      fields: Dict.mergeWith(acc, new, Array.concat),
    })

  let combineUnions = (u1: BaseUnresolvedOutput.union, u2: BaseUnresolvedOutput.union) => {
    BaseUnresolvedOutput.type_: u1.type_,
    base: ?Option.liftConcat(combineSelectionSets, u1.base, u2.base),
    members: Dict.mergeWith(u1.members, u2.members, combineSelectionSets),
  }

  let mergeUnions = (
    (init, unions): Array.nonEmpty<BaseUnresolvedOutput.union>,
  ): BaseUnresolvedOutput.union => Array.reduce(unions, init, combineUnions)

  let mergeLike = (t1: base, t2: base): base =>
    switch (t1, t2) {
    | (SelectionSet(ss1), SelectionSet(ss2)) => SelectionSet(combineSelectionSets(ss1, ss2))
    | (Union(u1), Union(u2)) => Union(combineUnions(u1, u2))
    | (SelectionSet(ss), Union({type_, ?base, members}))
    | (Union({type_, ?base, members}), SelectionSet(ss)) =>
      Union({
        type_,
        base: ?Option.liftConcat(combineSelectionSets, base, Some(ss)),
        members,
      })
    }

  let combineLike = ((t, ts): Array.nonEmpty<base>): base => Array.reduce(ts, t, mergeLike)
}

type t =
  | PrintString(string)
  | PrintType({
      namePath: array<string>,
      type_: BaseUnresolvedOutput.t,
      indent: int,
      seenFragments: Set.t<string>,
    })
  | PrintVariables({fields: Dict.t<InputType.t>, indent: int})
  | PrintDocument({document: ExecutableDefinitionNode.t, indent: int, seenFragments: Set.t<string>})
  | PrintDefinition({definition: ExecutableDefinitionNode.t})

let fromDefinitions = (definitions: array<AST.ExecutableDefinitionNode.t>, gqlTagModule) => {
  let res = Array.copy(definitions)
  Array.reverse(res)

  let operations = Array.filter(definitions, e =>
    switch e {
    | OperationDefinition(_) => true
    | _ => false
    }
  )

  [
    ...switch (definitions, operations) {
    | ([d], _) => Some(d)
    | (_, [o]) => Some(o)
    | (_, _) => None
    }
    ->Option.flatMap(ExecutableDefinitionNode.name)
    ->Option.map(s => PrintString(`include ${NameNode.value(s)}`))
    ->Option.toArray,
    ...Array.map(res, d => PrintDefinition({
      definition: d,
    })),
    PrintString(`let gql = ${gqlTagModule}.gql`),
  ]->List.fromArray
}

let joinPath = path => {
  // TODO: Make sure the separator doesn't
  //       show up in the path
  let sep = "_"
  Array.join(path, sep)
}

let nonTypenameSelections = selections =>
  SelectionSetNode.selections(selections)->Array.filter(s =>
    switch s {
    | Field({name}) => NameNode.value(name) != "__typename"
    | _ => true
    }
  )

type providedFragment = {
  definition: FragmentDefinitionNode.t,
  externalName: option<string>,
}

let process = (
  ~steps,
  ~fragments: Dict.t<providedFragment>,
  ~schema,
  ~baseTypesModule,
  ~scalarModule,
  ~nullType,
  ~listType,
  ~fragmentWrapper,
  ~appendToFragments,
  ~appendToQueries,
  ~appendToMutations,
  ~appendToSubscriptions,
) => {
  let formatModuleName = path => {
    let ls = switch Array.slice(path, ~start=0, ~end=2) {
    | ["t"] => ["t"]
    | ["t", _] => Array.sliceToEnd(path, ~start=1)
    | ["inner", "t"] => ["inner", ...Array.sliceToEnd(path, ~start=2)]
    | _ => raise(Invalid_type_name(path))
    }
    Array.map(ls, String.capitalize)->Array.join("")
  }
  let extractInputType = (typeNode: TypeNode.t): InputType.t => {
    open Schema
    let rec named = (nameNode): InputType.base => {
      let name = NameNode.value(nameNode)
      switch getType(schema, name)->Option.map(Named.parse)->Option.getOrExn(Unknown_type(name)) {
      | Scalar(s) => Scalar(Scalar.name(s))
      | Enum(e) => Enum(Enum.name(e))
      | InputObject(io) => Object(InputObject.name(io))
      | Object(_)
      | Interface(_)
      | Union(_) =>
        raise(Non_input_type(name))
      }
    }
    and base = (typeNode: TypeNode.t): InputType.t =>
      switch typeNode {
      | NamedType(n) => Base(named(n.name))
      | ListType({type_}) => List(base(type_))
      | NonNullType({type_}) =>
        NonNull(
          switch type_ {
          | NamedType({name}) => Base_nn(named(name))
          | NullListType({type_}) => List_nn(base(type_))
          },
        )
      }
    base(typeNode)
  }

  let extractSelectionType = (
    baseType: Schema.ValidForTypeCondition.t,
    selections: Array.nonEmpty<SelectionSetNode.selectionNode>,
    seenFragments: Set.t<string>,
  ): UnresolvedOutputType.result => {
    let rec extractFields = (
      node: SelectionSetNode.selectionNode,
      type_: Schema.ValidForTypeCondition.t,
    ) =>
      switch node {
      | Field({name, ?selectionSet}) =>
        BaseUnresolvedOutput.SelectionSet({
          type_: Schema.ValidForField.fromValidForTypeCondition(type_)->Option.getOrExn(
            Selection_on_union(Schema.ValidForTypeCondition.name(type_)),
          ),
          fields: Dict.fromArray([(AST.NameNode.value(name), Option.toArray(selectionSet))]),
        })
      | FragmentSpread(f) => {
          let fragmentName = NameNode.value(f.name)
          let fragmentEntry =
            Dict.get(fragments, fragmentName)->Option.getOrExn(Missing_fragment(fragmentName))
          Set.add(seenFragments, fragmentEntry.externalName->Option.getOr(fragmentName))
          let (fstSelection, rstSelections) =
            FragmentDefinitionNode.selectionSet(fragmentEntry.definition)
            ->nonTypenameSelections
            ->Array.headTail
            ->Option.getOrExn(Empty_fragment(fragmentName))
          UnresolvedOutputType.combineLike((
            extractFields(fstSelection, type_),
            Array.map(rstSelections, extractFields(_, type_)),
          ))
        }
      | InlineFragment({typeCondition, selectionSet}) => {
          let validatedBase = switch baseType {
          | Object(o) => raise(Invalid_inline_fragment(Schema.Object.name(o)))
          | Interface(i) => Schema.Interface.toAbstract(i)
          | Union(u) => Schema.Union.toAbstract(u)
          }
          let typeName = NameNode.value(NamedTypeNode.name(typeCondition))
          let selectionType =
            Schema.getType(schema, typeName)
            ->Option.getOrExn(Unknown_type(typeName))
            ->Schema.Named.parse
            ->Schema.ValidForTypeCondition.fromNamed
            ->Option.getOrExn(Invalid_type_condition(typeName))
          let merged =
            nonTypenameSelections(selectionSet)
            ->Array.map(extractFields(_, selectionType))
            ->Array.headTail
            ->Option.getOrExn(Empty_inline_fragment)
            ->UnresolvedOutputType.combineLike
          switch merged {
          | SelectionSet(ss) =>
            Union({
              type_: validatedBase,
              members: Dict.fromArray([(typeName, ss)]),
            })
          | Union({base, members}) => {
              let basePair = (typeName, base)
              let memberPairs =
                Dict.toArray(members)->Array.map(((k, v)) => (
                  k,
                  UnresolvedOutputType.combineSelectionSets(base, v),
                ))
              Union({
                type_: validatedBase,
                members: [basePair, ...memberPairs]->Dict.fromArray,
              })
            }
          | Union(u) => Union(u)
          }
        }
      | InlineFragment({selectionSet}) =>
        let (fstSelection, rstSelections) =
          nonTypenameSelections(selectionSet)
          ->Array.headTail
          ->Option.getOrExn(Empty_inline_fragment)
        UnresolvedOutputType.combineLike((
          extractFields(fstSelection, type_),
          Array.map(rstSelections, extractFields(_, type_)),
        ))
      }
    switch selections {
    | (FragmentSpread(f), []) => {
        let fragmentName = NameNode.value(f.name)
        let fragmentEntry =
          Dict.get(fragments, fragmentName)->Option.getOrExn(Missing_fragment(fragmentName))
        let fragmentModuleName = fragmentEntry.externalName->Option.getOr(fragmentName)
        Set.add(seenFragments, fragmentModuleName)
        SingleFragment(fragmentModuleName)
      }
    | (fst, rst) =>
      UnresolvedOutputType.combineLike((
        extractFields(fst, baseType),
        Array.map(rst, extractFields(_, baseType)),
      ))->Combined
    }
  }

  let processStep = (t): (list<t>, array<string>) =>
    switch t {
    | PrintString(str) => (list{}, [str])
    | PrintType({namePath, type_, indent, seenFragments}) => {
        let extractNamed = type_ =>
          Schema.Output.traverse(
            type_,
            ~onScalar=s => {
              let name = Schema.Scalar.name(s)
              Either.Left(name, `${scalarModule}.${String.pascalCase(name)}.t`)
            },
            ~onEnum=e => {
              let name = Schema.Enum.name(e)
              Either.Left(name, `${baseTypesModule}.${String.pascalCase(name)}.t`)
            },
            ~onObject=o => Either.Right(
              Schema.Object.name(o),
              Schema.ValidForTypeCondition.Object(o),
              i => i,
            ),
            ~onInterface=i => Either.Right(
              Schema.Interface.name(i),
              Schema.ValidForTypeCondition.Interface(i),
              i => i,
            ),
            ~onUnion=u => Either.Right(
              Schema.Union.name(u),
              Schema.ValidForTypeCondition.Union(u),
              i => i,
            ),
            ~onList=e =>
              switch e {
              | Left(n, a) => Left(n, `${listType}<${a}>`)
              | Right(n, t, w) => Right(n, t, s => `${listType}<${w(s)}>`)
              },
            ~onNull=e =>
              switch e {
              | Left(n, a) => Left(n, `${nullType}<${a}>`)
              | Right(n, t, w) => Right(n, t, s => `${nullType}<${w(s)}>`)
              },
          )
        let parseSelectionSet = (
          {type_, fields}: BaseUnresolvedOutput.selectionSet,
          seenFragments,
          ~midfix=?,
        ) => {
          let lookup = switch type_ {
          | Object(o) => Schema.Object.getFields(o)
          | Interface(i) => Schema.Interface.getFields(i)
          }
          Dict.toArray(fields)->Array.map(((rawKey, v)) => {
            let (key, alias) = GraphqlCodegen.Helpers.sanitizeFieldName(rawKey, fields)
            let fieldType =
              Dict.get(lookup, rawKey)
              ->Option.getOrExn(Unknown_field(rawKey))
              ->Schema.Field.type_
            let selections = Array.flatMap(v, nonTypenameSelections)
            let (value, neededType) = switch (Array.headTail(selections), extractNamed(fieldType)) {
            | (None, Left(_, str)) => (str, None)
            | (Some(fst, rst), Right(_, selections, wrapper)) =>
              switch extractSelectionType(selections, (fst, rst), seenFragments) {
              | SingleFragment(moduleName) => (wrapper(`${moduleName}.t`), None)
              | Combined(res) => {
                  let fieldPath = Option.mapOr(midfix, [...namePath, rawKey], m =>
                    [...namePath, m, rawKey]
                  )
                  (
                    wrapper(joinPath(fieldPath)),
                    Some(PrintType({namePath: fieldPath, type_: res, indent, seenFragments})),
                  )
                }
              }
            | (Some(_), Left(n, _)) => raise(Composite_type_without_fields(n))
            | (None, Right(n, _, _)) => raise(Simple_type_with_fields(n))
            }
            let mainLine = `  ${key}: ${value},`
            (
              switch alias {
              | None => [mainLine]
              | Some(a) => [`  @as("${a}")`, mainLine]
              },
              neededType,
            )
          })
        }
        let (lines, bases) = switch type_ {
        | SelectionSet(ss) => {
            let results = parseSelectionSet(ss, seenFragments)
            let lines = Array.flatMap(results, ((s, _)) => s)
            let bases = Array.filterMap(results, ((_, o)) => o)
            let name = joinPath(namePath)
            ([`type ${name} = {`, ...lines, `}`], bases)
          }
        | Union({type_, ?base, members}) => {
            let possibleTypes = Schema.getPossibleTypes(schema, type_)
            //Dict.toArray(members)
            let results = Array.map(possibleTypes, objectType => {
              let typeConditionName = Schema.Object.name(objectType)
              let selectionSet = switch (base, Dict.get(members, typeConditionName)) {
              | (Some(a), Some(b)) => Some(UnresolvedOutputType.combineSelectionSets(a, b))
              | (a, None) => a
              | (None, b) => b
              }
              Option.mapOr(
                selectionSet,
                ([`    | ${String.capitalize(typeConditionName)}`], []),
                ss => {
                  let fields = parseSelectionSet(ss, seenFragments, ~midfix=typeConditionName)
                  let lines = Array.flatMap(fields, ((s, _)) => s)
                  let bases = Array.filterMap(fields, ((_, o)) => o)
                  (
                    [
                      `    | ${String.capitalize(typeConditionName)}({`,
                      ...Array.map(lines, l => `  ${l}`),
                      "    })",
                    ],
                    bases,
                  )
                },
              )
            })
            let moduleName = formatModuleName(namePath)
            (
              [
                `module ${moduleName} = {`,
                `  @tag("__typename")`,
                `  type t =`,
                ...Array.flatMap(results, ((l, _)) => l),
                "}",
                `type ${joinPath(namePath)} = ${moduleName}.t`,
              ],
              Array.flatMap(results, ((_, t)) => t),
            )
          }
        }
        (List.fromArray(bases), Array.map(lines, l => `${String.repeat(" ", indent)}${l}`))
      }
    | PrintVariables({fields, indent}) => (
        list{},
        [
          "type variables = {",
          Dict.toArray(fields)
          ->Array.flatMap(((rawKey, inputType)) => {
            let (key, alias) = GraphqlCodegen.Helpers.sanitizeFieldName(rawKey, fields)
            let value = InputType.traverse(
              inputType,
              ~onScalar=s => `${scalarModule}.${String.pascalCase(s)}.t`,
              ~onEnum=s => `${baseTypesModule}.${String.pascalCase(s)}.t`,
              ~onObject=s => `${baseTypesModule}.${String.pascalCase(s)}.t`,
              ~onList=s => `${listType}<${s}>`,
              ~onNull=s => `${nullType}<${s}>`,
            )
            let mainLine = `  ${key}: ${value}`
            switch alias {
            | None => [mainLine]
            | Some(a) => [`  @as("${a}")`, mainLine]
            }
          })
          ->Array.join(",\n"),
          "}",
        ]->Array.map(l => `${String.repeat(" ", indent)}${l}`),
      )
    | PrintDocument({document, indent, seenFragments}) => (
        list{},
        [
          "let document = gql`",
          ...AST.ExecutableDefinitionNode.print(document)
          ->String.split("\n")
          ->Array.map(l => `  ${l}`),
          ...seenFragments
          ->Set.values
          ->Core__Iterator.toArrayWithMapper(moduleName =>
            `  \${${fragmentWrapper}(${moduleName}.document)}`
          ),
          "`",
        ]->Array.map(l => `${String.repeat(" ", indent)}${l}`),
      )
    | PrintDefinition({definition}) => {
        let definitionName = switch definition {
        | OperationDefinition(o) => Option.map(o.name, NameNode.value)
        | FragmentDefinition(f) => Some(NameNode.value(f.name))
        }
        let baseType = switch definition {
        | OperationDefinition({operation}) =>
          switch operation {
          | Query => Schema.getQueryType(schema)
          | Mutation => Schema.getMutationType(schema)
          | Subscription => Schema.getSubscriptionType(schema)
          }
          ->Option.getOrExn(Missing_base_type(operation))
          ->Schema.ValidForTypeCondition.Object
        | FragmentDefinition({name, typeCondition}) => {
            let conditionName = NamedTypeNode.name(typeCondition)->NameNode.value

            Schema.getType(schema, conditionName)
            ->Option.getOrExn(Unknown_type(NameNode.value(name)))
            ->Schema.Named.parse
            ->Schema.ValidForTypeCondition.fromNamed
            ->Option.getOrExn(Invalid_type_condition(conditionName))
          }
        }
        let (variableDefs, selectionSet) = switch definition {
        | OperationDefinition(o) => (Option.getOr(o.variableDefinitions, [])->Some, o.selectionSet)
        | FragmentDefinition(f) => (f.variableDefinitions, f.selectionSet)
        }
        let variables = Option.map(variableDefs, vds =>
          Array.map(vds, a => {
            (
              VariableDefinitionNode.variable(a)
              ->VariableNode.name
              ->NameNode.value,
              VariableDefinitionNode.type_(a)->extractInputType,
            )
          })->Dict.fromArray
        )
        let seenFragments = Set.make()
        let selectionSteps =
          selectionSet
          ->nonTypenameSelections
          ->Array.headTail
          ->Option.getOrExn(Empty_definition(Option.getOr(definitionName, "<unnamed operation>")))
          ->extractSelectionType(baseType, _, seenFragments)

        let indent = 2

        (
          list{
            switch selectionSteps {
            | SingleFragment(moduleName) => PrintString(`${moduleName}.t`)->Some
            | Combined(type_) =>
              PrintType({
                namePath: ["t"],
                type_,
                indent,
                seenFragments,
              })->Some
            },
            PrintDocument({document: definition, indent, seenFragments})->Some,
            Option.map(variables, v => PrintVariables({fields: v, indent})),
            PrintString(`module ${Option.getOr(definitionName, "Operation")} = {`)->Some,
          }->List.filterMap(e => e),
          Array.keepSome([
            switch definition {
            | FragmentDefinition(_) => appendToFragments
            | OperationDefinition({operation: Query}) => appendToQueries
            | OperationDefinition({operation: Mutation}) => appendToMutations
            | OperationDefinition({operation: Subscription}) => appendToSubscriptions
            }->Option.map(section =>
              section
              ->String.split("\n")
              ->Array.map(l => `${String.repeat(" ", indent)}${l}`)
              ->Array.join("\n")
            ),
            Some("}"),
          ]),
        )
      }
    }
  let rec main = (remaining, output) => {
    switch remaining {
    | list{} => output
    | list{nxt, ...rst} => {
        let (newSteps, newLines) = processStep(nxt)
        main(List.concat(newSteps, rst), Array.join([...newLines, output], "\n"))
      }
    }
  }
  main(steps, ``)
}
