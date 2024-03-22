@@directive(`#!/usr/bin/env node`)
module Path = NodeJs.Path

let usage = `Usage:
  generate                                                | Generates all GraphQL code.
    [--config <path>]                                     | Filepath to GraphQL config.
    [--src <path>]                                        | The source folder for where to look for ReScript files.
    [--output <path>]                                     | Where to emit all generated files.
    [--watch]                                             | Runs this command in watch mode.

  unused-selections                                       | Check if we there are unused selections in your GraphQL queries.
    [--ci]                                                | Run in CI mode.

  extract <filePath>                                      | Extract all %graphql tags in file at <filePath>.`

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

type config = {
  ppxConfigRef: ref<Codegen.ppxConfig>,
  mainConfigPath: string,
  outDir: string
}

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
      let configPath = RescriptEmbedLang.CliArgs.getArgValue(args, ["--config"])
      let outDir = RescriptEmbedLang.CliArgs.getArgValue(args, ["--output"])->OptionPlus.getOrPanic("Missing output file")
      let (config, mainConfigPath, schemaPatterns) = await Codegen.getConfig(configPath)
      (await Codegen.runBase(config.mainConfig))->ignore
      let (schemaFilePatterns, additionalIgnorePatterns) = switch schemaPatterns {
        | {affirmative: []} => ([], [])
        | { affirmative, negated} => (affirmative, negated)
      }
      let ppxConfigRef = ref(config)
      let additionalFileWatchers = {
        open RescriptEmbedLang
        let onChange = async (c: RescriptEmbedLang.watcherOnChangeConfig) => {
          (await Codegen.runBase(ppxConfigRef.contents.mainConfig))->ignore
          await c.runGeneration()
        }
        Array.concat(
          [{RescriptEmbedLang.filePattern: mainConfigPath, onChange}],
          Array.map(schemaFilePatterns, filePattern => {filePattern, onChange})
        )
      }
      RescriptEmbedLang.SetupResult({
        config: { ppxConfigRef, mainConfigPath, outDir },
        additionalFileWatchers,
        additionalIgnorePatterns
      })
    },
    ~generate=async ({config, content, path}) => {
      switch await Codegen.runDocument(config.ppxConfigRef.contents, path, content) {
        | [] => panic("No results returned")
        | [val] => Ok(RescriptEmbedLang.NoModuleName({content: val.content}))
        | _ => panic("Multiple results returned")
      }
    },
  )

  RescriptEmbedLang.runCli(emitter)
}

main()->ignore
