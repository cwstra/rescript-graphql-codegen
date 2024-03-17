@@directive(`#!/usr/bin/env node`)
module Path = NodeJs.Path

let usage = `Usage:
  generate                                                | Generates all GraphQL code.
    [--schema <path>]                                     | Filepath to your graphql schema.
    [--output <path>]                                     | Where to emit all generated files.
    [--src <path>]                                        | The source folder for where to look for ReScript files.
    [--watch]                                             | Runs this command in watch mode.

  unused-selections                                       | Check if we there are unused selections in your EdgeQL queries.
    [--ci]                                                | Run in CI mode.

  extract <filePath>                                      | Extract all %edgeql tags in file at <filePath>.`

type config = {
  run: (~inputSdl: string, ~filePath: string) => promise<array<Codegen.fileOutput>>,
  schemaPath: string,
}

type errorInFile = {
  startLoc: RescriptEmbedLang.loc,
  endLoc: RescriptEmbedLang.loc,
  errorMessage: string,
}

let isInConfigDir = async () => {
  let cwd = NodeJs.Process.process->NodeJs.Process.cwd
  let bsconfig = Path.resolve([cwd, "bsconfig.json"])
  let rescriptJson = Path.resolve([cwd, "rescript.json"])

  try {
    await NodeJs.Fs.access(bsconfig)
    true
  } catch {
  | Exn.Error(_) =>
    try {
      await NodeJs.Fs.access(rescriptJson)
      true
    } catch {
    | Exn.Error(_) => false
    }
  }
}

let example =
      {run: Codegen.run(~schema="", ~pluginName="", ~scalarModule="", ~baseTypesModule="", ...), schemaPath: ""}

let main = async () => {
  let errors = Map.make()

  let syncErrors = async () => {
    let isInConfigDir = await isInConfigDir()
    if isInConfigDir {
      Path.resolve([
        NodeJs.Process.process->NodeJs.Process.cwd,
        "lib",
        "bs",
        ".generator.graphql.log",
      ])->NodeJs.Fs.writeFileSync(
        errors
        ->Map.entries
        ->Iterator.toArray
        ->Array.reduce(Dict.make(), (dict, (filePath, errorMap)) => {
          Dict.set(dict, filePath, Dict.valuesToArray(errorMap))
          dict
        })
        ->JSON.stringifyAny
        ->Option.getOr("")
        ->NodeJs.Buffer.fromString,
      )
    }
  }

  let pruneErrorsForModuleInFile = (~path, ~moduleName) =>
    switch (Map.get(errors, path), moduleName) {
    | (Some(fileErrors), Some(moduleName)) => Dict.delete(fileErrors, moduleName)
    | _ => ()
    }

  let setErrorForModuleInFile = (~path, ~error: errorInFile, ~moduleName) =>
    switch (moduleName, Map.get(errors, path)) {
    | (Some(moduleName), None) => Map.set(errors, path, Dict.fromArray([(moduleName, error)]))
    | (Some(moduleName), Some(fileErrors)) => Dict.set(fileErrors, moduleName, error)
    | (None, _) => ()
    }

  let emitter = RescriptEmbedLang.make(
    ~extensionPattern= Generic("graphql"),
    ~cliHelpText=usage,
    ~setup=async ({args}) => {
      let schema =
        RescriptEmbedLang.CliArgs.getArgValue(args, ["--schema"])->Option.getOrPanic(
          "--schema argument required",
        )
      let pluginName =
        RescriptEmbedLang.CliArgs.getArgValue(args, ["--plugin"])->Option.getOrPanic(
          "--plugin argument required",
        )
      let scalarModule =
        RescriptEmbedLang.CliArgs.getArgValue(args, ["--scalar-module"])->Option.getOrPanic(
          "--scalar-module argument required",
        )
      let baseTypesModule =
        RescriptEmbedLang.CliArgs.getArgValue(args, ["--base-types-module"])->Option.getOrPanic(
          "---base-types-module argument required",
        )

      {run: Codegen.run(~schema, ~pluginName, ~scalarModule, ~baseTypesModule, ...), schemaPath: schema}
    },
    ~generate=async ({config, content, path, location}) => {
      Console.log2("gen", content)
      let results = await config.run(~inputSdl=content, ~filePath=path)
      Console.log2("results", results)
/*, moduleName: "Test"*/
      Ok(RescriptEmbedLang.NoModuleName({content: switch results {
        | [] => panic("No results returned")
        | [val] => val.content
        | _ => panic("Multiple results returned")
      }}))
    },
    ~onWatch=async ({config, runGeneration, debug}) => {
      // TODO: watch schema file
      //let checkForSchemaChanges = async () => {
      //  try {
      //    NodeJs.Fs.PromiseAPI.
      //    debug("[schemma change detection] Polling for schema changes...")
      //  }
      //}
      ()
    },
  )

  RescriptEmbedLang.runCli(emitter)
}

main()->ignore
