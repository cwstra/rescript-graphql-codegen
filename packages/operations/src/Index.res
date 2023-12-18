open Graphql
open GraphqlCodegen

type config = unit
let default: Plugin.codegenPlugin<config> = {
  plugin: async (schema, documents, _) => {
    let b = schema
    Plugin.PluginOutput.String("")
  }
}
