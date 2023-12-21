open Graphql

type presetFnArgs<'config, 'configuredPlugin, 'pluginConfig, 'pluginMap, 'pluginContext> = {
  presetConfig: 'config,
  baseOutputDir: string,
  plugins: array<'configuredPlugin>,
  schema: AST.DocumentNode.t,
  schemaAst?: Schema.t,
  documents: array<Base.documentFile>,
  config: 'pluginConfig,
  pluginMap: 'pluginMap,
  pluginContext: 'pluginContext,
}

type generateOptions<'config, 'configuredPlugin, 'pluginConfig, 'pluginMap, 'pluginContext> = {
  filename: string,
  plugins: array<'configuredPlugin>,
  schema: AST.DocumentNode.t,
  schemaAst?: Schema.t,
  documents: array<Base.documentFile>,
  config: 'pluginConfig,
  pluginMap: 'pluginMap,
  pluginContext: 'pluginContext
}

@module("graphql")
external buildASTSchema: (AST.DocumentNode.t, ~options: 'pluginConfig=?) => Schema.t =
  "buildASTSchema"

type outputPreset<'config, 'configuredPlugin, 'pluginConfig, 'pluginMap, 'pluginContext> = {
  buildGeneratesSection: presetFnArgs<
    'config,
    'configuredPlugin,
    'pluginConfig,
    'pluginMap,
    'pluginContext,
  > => promise<
    array<
      generateOptions<'config, 'configuredPlugin, 'pluginConfig, 'pluginMap, 'pluginContext>,
    >,
  >,
}
