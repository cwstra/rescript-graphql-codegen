type ppxGenerates
type filePath = string
type gqlDocument = string

module SchemaPatterns = {
  type pattern = string
  @module("./wrapper.mjs")
  external filePathMatchesPatterns: (filePath, array<pattern>) => bool = "testPattern"
  type t = {
    affirmative: array<pattern>,
    negated: array<pattern>
  }
}

module CodegenConfig = {
  type t
  @module("./wrapper.mjs")
  external getGeneratesEntry: t => option<ppxGenerates> = "getGeneratesEntry"
  @module("./wrapper.mjs")
  external getSchemaPatterns: t => SchemaPatterns.t = "getSchemaPatterns"
}

type ppxConfig = {
  mainConfig: CodegenConfig.t,
  generatesEntry: ppxGenerates
}

@module("./wrapper.mjs")
external getCodegenConfig: (option<filePath>) => promise<option<(filePath, CodegenConfig.t)>> = "getCodegenConfig"

let getConfig = async (configFilePath) => {
  let (mainConfigPath, mainConfig) =
    (await getCodegenConfig(configFilePath))
    ->OptionPlus.getOrPanic("Codegen config not found")
  let generatesEntry =
    CodegenConfig.getGeneratesEntry(mainConfig)
    ->OptionPlus.getOrPanic("Missing ppxGenerates property in codegen config")
  ({mainConfig, generatesEntry}, mainConfigPath, CodegenConfig.getSchemaPatterns(mainConfig))
}

type fileOutput = {
  filename: filePath,
  content: string,
}

@module("./wrapper.mjs")
external runBase: CodegenConfig.t => promise<array<fileOutput>> = "runBase"

@module("./wrapper.mjs")
external runDocument: (ppxConfig, filePath, gqlDocument) => promise<array<fileOutput>> = "runDocument"
