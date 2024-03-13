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

let default = (schema, pluginName) => {
  (inputSdl, file_path) => {
    generate(
      {
        schema,
        documents: inputSdl,
        generates: Js.Dict.fromArray([(file_path, {plugins: [pluginName]})]),
      },
      true,
    )->ignore
  }
}
