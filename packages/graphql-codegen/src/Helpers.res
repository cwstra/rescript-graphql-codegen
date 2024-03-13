open Graphql

exception Unknown_field(string, string)

let getFieldType = (baseType: Schema.ValidForField.t, fieldName) => {
  let fields = switch baseType {
  | Object(o) => Schema.Object.getFields(o)
  | Interface(i) => Schema.Interface.getFields(i)
  }
  switch Dict.get(fields, fieldName) {
  | None =>
    raise(
      Unknown_field(
        switch baseType {
        | Object(o) => Schema.Object.name(o)
        | Interface(i) => Schema.Interface.name(i)
        },
        fieldName,
      ),
    )
  | Some(f) => Schema.Field.type_(f)
  }
}

let keywords = [
  "await",
  "open",
  "true",
  "false",
  "let",
  "and",
  "rec",
  "as",
  "exception",
  "assert",
  "lazy",
  "if",
  "else",
  "for",
  "in",
  "while",
  "switch",
  "when",
  "external",
  "type",
  "private",
  "constraint",
  "mutable",
  "include",
  "module",
  "try",
]

let sanitizeFieldName = (original, fields: Dict.t<_>) =>
  if Array.includes(keywords, original) {
    let rec wrapField = fieldName => {
      let newName = `${fieldName}_`
      switch Dict.get(fields, newName) {
      | Some(_) => wrapField(newName)
      | None => (newName, Some(original))
      }
    }
    wrapField(original)
  } else {
    (original, None)
  }

exception Cyclic_topology
exception Empty_argument

type topologyNode<'value> = {
  name: string,
  node: 'value,
  dependsOn: array<string>,
}

let topologicalSort = (~input, ~mapSingle, ~mapCycle=?) => {
  let rateNode = n => Array.length(n.dependsOn)
  let removeHandledDependencies = (node, names) => {
    ...node,
    dependsOn: Array.filter(node.dependsOn, dependency => !Array.includes(names, dependency)),
  }
  let handleCycle = switch mapCycle {
  | None => _ => raise(Cyclic_topology)
  | Some(mapCycle) =>
    ((n, ns)) => {
      let rec go = (collected, border, untouched, dependencies) =>
        switch Array.flatMap(border, b => b.dependsOn)->Array.uniqBy(v => v) {
        | [] => (mapCycle(Array.concat(collected, border)), untouched, dependencies)
        | newDepNames => {
            let remove = removeHandledDependencies(_, newDepNames)
            let newCollected = Array.concat(collected, Array.map(border, remove))
            let (newBorder, newUntouched) = Array.map(untouched, remove)->Either.partitionMap(n =>
              if Array.includes(newDepNames, n.name) {
                Either.Left(n)
              } else {
                Either.Right(n)
              }
            )
            go(newCollected, newBorder, newUntouched, Array.concat(dependencies, newDepNames))
          }
        }
      go([], [n], ns, [])
    }
  }
  let rec sort = (unsortedFragments, ~sortedFragments=[]) => {
    Array.sort(unsortedFragments, (f1, f2) => Ordering.compare(rateNode(f1), rateNode(f2)))
    switch Array.takeDropWhile(unsortedFragments, f => rateNode(f) == 0) {
    | ([], dependent) => {
        let (cycleEntry, remainingDependents, handledDeps) =
          Array.headTail(dependent)->Option.getOrExn(Empty_argument)->handleCycle
        Console.log3(cycleEntry, remainingDependents, handledDeps)
        let newSortedFragments = Array.concat(sortedFragments, [cycleEntry])
        if Array.length(remainingDependents) == 0 {
          newSortedFragments
        } else {
          sort(
            Array.map(remainingDependents, removeHandledDependencies(_, handledDeps)),
            ~sortedFragments=newSortedFragments,
          )
        }
      }
    | (independent, []) => Array.concat(sortedFragments, Array.map(independent, mapSingle))
    | (independent, dependent) =>
      sort(
        Array.map(dependent, removeHandledDependencies(_, Array.map(independent, i => i.name))),
        ~sortedFragments=Array.concat(sortedFragments, Array.map(independent, mapSingle)),
      )
    }
  }
  switch input {
  | [] => []
  | arr => sort(arr)
  }
}

let sortFragmentsTopologically = (definitions: array<AST.FragmentDefinitionNode.t>) => {
  open AST
  let rec extractDependsFromSelections = (selections, ~fragmentNames=[]) => {
    let newFragmentNames = Array.filterMap(selections, s =>
      switch s {
      | SelectionSetNode.FragmentSpread({name}) => Some(NameNode.value(name))
      | _ => None
      }
    )
    let nestedSelections = Array.flatMap(selections, s =>
      switch s {
      | SelectionSetNode.Field({selectionSet}) => selectionSet->SelectionSetNode.selections
      | SelectionSetNode.Field(_) => []
      | InlineFragment({selectionSet}) => selectionSet->SelectionSetNode.selections
      | FragmentSpread(_) => []
      }
    )
    switch nestedSelections {
    | [] => fragmentNames
    | _ =>
      extractDependsFromSelections(
        nestedSelections,
        ~fragmentNames=Array.concat(fragmentNames, newFragmentNames),
      )
    }
  }
  let withDepends = definitions->Array.map(node => {
    {
      name: node->FragmentDefinitionNode.name->NameNode.value,
      node,
      dependsOn: FragmentDefinitionNode.selectionSet(node)
      ->SelectionSetNode.selections
      ->extractDependsFromSelections,
    }
  })
  topologicalSort(~input=withDepends, ~mapSingle=f => f.node)
}

type inputObjectSortResult =
  | NonRec(Schema.InputObject.t)
  | Rec(array<Schema.InputObject.t>)

let sortInputObjectsTopologically = (definitions: array<Schema.InputObject.t>) => {
  let withDepends = Array.map(definitions, node => {
    name: Schema.InputObject.name(node),
    node,
    dependsOn: Schema.InputObject.getFields(node)
    ->Dict.valuesToArray
    ->Array.filterMap(field => {
      let rec go = f =>
        switch Schema.Input.parse(f) {
        | InputObject(io) => Some(Schema.InputObject.name(io))
        | List(l) => Schema.List.ofType(l)->go
        | NonNull(nn) =>
          switch Schema.NonNull.ofType(nn)->Schema.Input.parse_nn {
          | InputObject(io) => Some(Schema.InputObject.name(io))
          | List(l) => Schema.List.ofType(l)->go
          | Scalar(_) | Enum(_) => None
          }
        | Scalar(_) | Enum(_) => None
        }
      go(Schema.InputField.type_(field))
    }),
  })
  topologicalSort(
    ~input=withDepends,
    ~mapSingle=f => NonRec(f.node),
    ~mapCycle=fs => {
      Rec(Array.map(fs, f => f.node))
    },
  )
}
