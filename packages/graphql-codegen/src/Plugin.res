let bleh: GraphQL.AST.operationDefinitionNode = OperationDefinition({
  operation: Query,
  selectionSet: SelectionSet({
    selections: []
  }),
})

type source = {
  document: GraphQL.AST.documentNode,
  schema: GraphQL.Schema.t,
  rawSDL?: string,
  location?: string,
}
type documentFile = source

module PluginOutput = {
  @unboxed
  type t =
    | String(string)
    | Complex({content: string, prepend?: array<string>, append?: array<string>})
}

module AddToSchemaResult = {
  @unboxed
  type t =
    | String(string)
    | DocumentNode(GraphQL.AST.documentNode)
}

type pluginFunction<'config> = (
  GraphQL.Schema.t,
  array<documentFile>,
  'config,
) => promise<PluginOutput.t>
type pluginValidateFn<'config> = (GraphQL.Schema.t, array<documentFile>, 'config) => promise<unit>

type codegenPlugin<'config> = {
  plugin: pluginFunction<'config>,
  addToSchema?: 'config => AddToSchemaResult.t,
  validate?: pluginValidateFn<'config>,
}
