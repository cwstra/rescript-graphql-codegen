type configuredOutput = {plugins?: array<string>}

type config<'innerConfig> = {
  schema?: string,
  documents?: string,
  config?: 'innerConfig,
  generates: Js.Dict.t<configuredOutput>,
}

type fileOutput = {
  filename: string,
  content: string,
}

@module("@graphql-codegen/cli")
external generate: (config<'innerConfig>, bool) => array<fileOutput> = "generate"

let fn = (~a, ~b) => a + b

let run = (~schema, ~pluginName, ~inputSdl, ~filePath) =>
  generate(
    {
      schema,
      documents: inputSdl,
      generates: Js.Dict.fromArray([(filePath, {plugins: [pluginName]})]),
    },
    true,
  )
