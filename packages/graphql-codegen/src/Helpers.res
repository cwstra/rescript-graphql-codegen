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

let topologicalSort = (input, getValue, updateValue, mapOut) => {
  let rec sort = (unsortedFragments, ~sortedFragments=[]) => {
    Array.sort(unsortedFragments, (f1, f2) => Ordering.compare(getValue(f1), getValue(f2)))
    switch Array.takeDropWhile(unsortedFragments, f => getValue(f) == 0) {
    | ([], _) => raise(Cyclic_topology)
    | (independent, []) => Array.concat(sortedFragments, independent)->Array.map(mapOut)
    | (independent, dependent) =>
      sort(
        Array.map(dependent, fragment => updateValue(fragment, independent)),
        ~sortedFragments=Array.concat(sortedFragments, independent),
      )
    }
  }
  switch input {
  | [] => []
  | arr => sort(arr)
  }
}

type fragmentWithDeps = {
  name: string,
  node: AST.FragmentDefinitionNode.t,
  dependsOn: array<string>,
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
  topologicalSort(
    withDepends,
    f => f.dependsOn->Array.length,
    (f, is) => {
      ...f,
      dependsOn: Array.filter(f.dependsOn, dependency => Array.some(is, i => i.name == dependency)),
    },
    f => f.node,
  )
}

type ioWithDeps = {
  name: string,
  node: Schema.InputObject.t,
  dependsOn: array<string>,
}
// TODO?: Handle dependency cycles
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
    withDepends,
    io => io.dependsOn->Array.length,
    (io, is) => {
      ...io,
      dependsOn: Array.filter(io.dependsOn, dependency =>
        Array.some(is, i => i.name == dependency)
      ),
    },
    f => f.node,
  )
}
