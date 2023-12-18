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
    | DocumentNode(Graphql.AST.DocumentNode.t)
}

type pluginFunction<'config> = (
  Graphql.Schema.t,
  array<Base.documentFile>,
  'config,
) => promise<PluginOutput.t>
type pluginValidateFn<'config> = (Graphql.Schema.t, array<Base.documentFile>, 'config) => promise<unit>

type codegenPlugin<'config> = {
  plugin: pluginFunction<'config>,
  addToSchema?: 'config => AddToSchemaResult.t,
  validate?: pluginValidateFn<'config>,
}
