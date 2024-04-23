module PluginOutput = {
  @unboxed
  type t =
    | String(string)
    | Complex({content: string, prepend?: array<string>, append?: array<string>})
}

module AddToSchemaResult = {
  type t
  type parsed =
    | String(string)
    | DocumentNode(Graphql.AST.DocumentNode.t)
  let parse: t => parsed = %raw(`
    raw => typeof raw === 'string' ? {TAG: "String", _0: raw} : {TAG: "DocumentNode", _0: raw}
  `)
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
