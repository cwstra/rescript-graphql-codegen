open Graphql

type presetFnArgs<'config, 'configuredPlugin, 'pluginConfig, 'codegenPlugin, 'codegenContext> = {
  presetConfig: 'config,
  baseOutputDir: string,
  plugins: array<'configuredPlugin>,
  schema: AST.DocumentNode.t,
  schemaAst?: Schema.t,
  documents: array<Base.documentFile>,
  config: 'pluginConfig,
  pluginMap: 'codegenPlugin,
  pluginContext: 'codegenContext,
}

type generateOptions<'config, 'configuredPlugin, 'pluginConfig, 'codegenPlugin, 'codegenContext> = {
  filename: string,
  plugins: array<'configuredPlugin>,
  schema: AST.DocumentNode.t,
  schemaAst?: Schema.t,
  documents: array<Base.documentFile>,
  config: 'pluginConfig,
}

@module("graphql")
external buildASTSchema: (AST.DocumentNode.t, ~options: 'pluginConfig=?) => Schema.t =
  "buildASTSchema"

type outputPreset<'config, 'configuredPlugin, 'pluginConfig, 'codegenPlugin, 'codegenContext> = {
  buildGeneratesSection: presetFnArgs<
    'config,
    'configuredPlugin,
    'pluginConfig,
    'codegenPlugin,
    'codegenContext,
  > => promise<
    array<
      generateOptions<'config, 'configuredPlugin, 'pluginConfig, 'codegenPlugin, 'codegenContext>,
    >,
  >,
}
