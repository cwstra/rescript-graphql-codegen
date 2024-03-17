type configuredOutput = {
  plugins: array<string>,
  documents: string
}

type operationsConfig = {
  baseTypesModule: string,
  scalarModule: string
}
type config<'innerConfig> = {
  schema?: string,
  documents?: string,
  config?: 'innerConfig,
  generates: Js.Dict.t<configuredOutput>,
}

type fileOutput = {filename: string,
  content: string,
}

@module("@graphql-codegen/cli")
external generate: (config<'innerConfig>, bool) => promise<array<fileOutput>> = "generate"

let run = (~schema, ~pluginName, ~scalarModule, ~baseTypesModule, ~inputSdl, ~filePath) =>
  generate({
      schema,
      config: {
        baseTypesModule,
        scalarModule
      },
      generates: Js.Dict.fromArray([(filePath, {plugins: [pluginName], documents: inputSdl})]),
    },
    false,
  )
