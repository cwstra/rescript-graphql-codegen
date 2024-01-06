open Graphql
open GraphqlCodegen

type config = {
  scalarModule: string,
  baseTypesPath: string,
  baseTypesModule: string,
}

let plugin: Plugin.pluginFunction<config> = async (schema, documents, config) => {
  let (fragments, operations) =
    Array.flatMap(documents, d => d.document.definitions)
    ->Array.filterMap(d =>
      switch d {
      | OperationDefinition(o) =>
        Some(
          Either.Right(
            AST.OperationDefinitionNode.OperationDefinition({
              loc: ?o.loc,
              operation: o.operation,
              name: ?o.name,
              variableDefinitions: ?o.variableDefinitions,
              directives: ?o.directives,
              selectionSet: o.selectionSet,
            }),
          ),
        )
      | FragmentDefinition(f) =>
        Some(
          Either.Left(
            AST.FragmentDefinitionNode.FragmentDefinition({
              loc: ?f.loc,
              name: f.name,
              variableDefinitions: ?f.variableDefinitions,
              typeCondition: f.typeCondition,
              directives: ?f.directives,
              selectionSet: f.selectionSet,
            }),
          ),
        )
      | _ => None
      }
    )
    ->Either.partition(f => f)
  let fragmentLookup =
    Array.map(fragments, f => (
      AST.FragmentDefinitionNode.name(f)->AST.NameNode.value,
      f,
    ))->Dict.fromArray

  let sorted = Array.concat(
    Helpers.sortFragmentsTopologically(fragments)->Array.map(
      AST.ExecutableDefinitionNode.fromFragmentDefinition,
    ),
    operations->Array.map(AST.ExecutableDefinitionNode.fromOperationDefinition),
  )
  let init = WorkItem.fromDefinitions(sorted)

  let res = WorkItem.process(
    ~steps=init,
    ~fragments=fragmentLookup,
    ~schema,
    ~baseTypesModule=config.baseTypesModule,
    ~scalarModule=config.scalarModule,
  )

  Plugin.PluginOutput.String(res)
}
