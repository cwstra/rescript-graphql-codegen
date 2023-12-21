open Graphql

exception Cyclic_fragments

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
  let rec sort = (unsortedFragments: array<fragmentWithDeps>, ~sortedFragments=[]) => {
    Array.sort(unsortedFragments, (f1, f2) =>
      Ordering.compare(f1.dependsOn->Array.length, f2.dependsOn->Array.length)
    )
    switch Array.takeDropWhile(unsortedFragments, f => f.dependsOn->Array.length == 0) {
    | ([], _) => raise(Cyclic_fragments)
    | (independent, []) => Array.concat(sortedFragments, independent)->Array.map(f => f.node)
    | (independent, dependent) =>
      sort(
        Array.map(dependent, fragment => {
          ...fragment,
          dependsOn: Array.filter(fragment.dependsOn, dependency =>
            Array.some(independent, i => i.name == dependency)
          ),
        }),
        ~sortedFragments=Array.concat(sortedFragments, independent),
      )
    }
  }
  sort(withDepends)
}
