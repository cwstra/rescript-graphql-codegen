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
  generatesEntry: ppxGenerates,
  schemaPatterns: SchemaPatterns.t
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
  ({mainConfig, generatesEntry, schemaPatterns: CodegenConfig.getSchemaPatterns(mainConfig)}, mainConfigPath)
}

type fileOutput = {
  filename: filePath,
  content: string,
}

@module("./wrapper.mjs")
external run: (ppxConfig, filePath, gqlDocument) => promise<array<fileOutput>> = "run"

@module("./wrapper.mjs")
external getPathBase: string => string = "getPathBase"

let systemPathToNixPath = {
  let re = RegExp.fromStringWithFlags("\\\\", ~flags="g")
  String.replaceRegExp(_, re, "/")
}
let nixPathToSystemPath = {
  let re = RegExp.fromStringWithFlags("/", ~flags="g")
  String.replaceRegExp(_, re, NodeJs.Path.sep)
}

let headTail = arr =>
    Array.get(arr, 0)
    ->Option.map(h => (h, Array.sliceToEnd(arr, ~start=1)))

let takeWhileWithIndex = (arr, pred) =>
  switch Array.findIndexWithIndex(arr, (e, i) => !pred(e, i)) {
    | -1 => arr
    | end => Array.slice(arr, ~start=0, ~end)
  }

let trace = t => {Console.log(t); t}

let longestCommonPrefix = paths =>
  switch headTail(paths) {
    | None => ""
    | Some(head, []) => head
    | Some(head, tail) => {
      let splitTail = Array.map(tail, p => String.split(p, NodeJs.Path.sep))
      String.split(head, NodeJs.Path.sep)
      ->takeWhileWithIndex(
        (h, i) => Array.every(splitTail, tail => Option.mapOr(Array.get(tail, i), false, t => t === h))
      )
      ->Array.joinWith(NodeJs.Path.sep)
    }
  }

let getCwd = () =>
  NodeJs.Process.cwd(NodeJs.Process.process)


let findHighestCommonDirectory = async files => {
  open NodeJs.Path
  let longestCommonPrefix =
    Array.map(files, f => isAbsolute(f) ? f : resolve([f]))
    ->Array.map(systemPathToNixPath)
    ->Array.map(getPathBase)
    ->Array.map(nixPathToSystemPath)
    ->longestCommonPrefix
  try {
    await NodeJs.Fs.access(longestCommonPrefix)
    longestCommonPrefix
  } catch {
    | Js.Exn.Error(_) => getCwd()
  }
}

type parcelEvent = {
  @as("type") type_: string,
  path: string
}
type parcelIgnore = {ignore: array<filePath>}
type parcelSubscription = {
  unsubscribe: () => promise<unit>
}
type parcelWatcher = {
  subscribe: (
    filePath,
    (unknown, array<parcelEvent>) => promise<unit>,
    parcelIgnore
  ) => promise<parcelSubscription>,
}

@module("./wrapper.mjs")
external getParcel: unit => promise<parcelWatcher> = "getParcel"

@module("debounce")
external debounce: (unit => unit, int) => unit => unit = "default"

module AbortSignal = {
  type t
  type event = | @as("abort") Abort
  @send external addEventListener: (t, event, unit => unit) => unit = "addEventListener"
}
module AbortController = {
  type t
  @new external make: unit => t = "AbortController"
  @send external abort: (t, unit => unit) => unit = "abort"
  @get external signal: t => AbortSignal.t = "signal"
}

module ProcessPlus = {
  open NodeJs.Process
  @send external onSigIntOnce: (t, @as("SIGINT") _,unit => unit) => unit = "once"
  @send external onSigTermOnce: (t, @as("SIGTERM") _, unit => unit) => unit = "once"
}

type watcherResult = {
  stopWatching: unit => promise<unit>,
  runningWatcher: promise<unit>
}

let createWatcher = (
  mainConfigPath,
  outDir,
  configRef,
  runGeneration
) => {
  Console.log2("mainConfigPath", mainConfigPath)
  let shouldRebuild = absolutePath => {
    let relativePath = NodeJs.Path.relative(~from= getCwd(), ~to_=absolutePath)
    let {affirmative, negated} = configRef.contents.schemaPatterns
    !SchemaPatterns.filePathMatchesPatterns(relativePath, negated) &&
     SchemaPatterns.filePathMatchesPatterns(relativePath, affirmative)
  }
  let subscription: ref<option<parcelSubscription>> = ref(None)
  let runWatcher = async abortSignal => {
    try {
      let parcelWatcher = await getParcel()
      let isShutdown = ref(false)
      let debouncedExec = debounce(() => {
        if !isShutdown.contents {
          runGeneration()->ignore
        }
      }, 100)
      let rec makeSubscription = hcd => {
        let ignored = ["**/.git/**", {
          open NodeJs.Path
          relative(~from=hcd, ~to_=resolve([getCwd(), outDir]))
        }]
        parcelWatcher.subscribe(
          hcd,
          async (_, events) => {
            let _ = await Promise.all(
              Array.map(events, async ({type_, path}) => {
                if shouldRebuild(path) {
                  if (type_ === "update" && mainConfigPath === path) {
                    let (newConfig, _) = await getConfig(Some(mainConfigPath))
                    configRef := newConfig
                    let newHCD = await findHighestCommonDirectory(Array.concat([mainConfigPath], newConfig.schemaPatterns.affirmative))
                    if hcd !== newHCD {
                      await subscription.contents->Option.mapOr(Promise.resolve(), s => s.unsubscribe())
                      subscription := Some(await makeSubscription(newHCD))
                    }
                  }
                  debouncedExec()
                }
              })
            )
          },
          {ignore: ignored}
        )
      }
      subscription := Some(
        await makeSubscription(
          await findHighestCommonDirectory(Array.concat([mainConfigPath], configRef.contents.schemaPatterns.affirmative))
        )
      )
      let shutdown = () => {
        isShutdown := true
        subscription.contents->Option.mapOr(Promise.resolve(), s => s.unsubscribe())->ignore
      }
      AbortSignal.addEventListener(abortSignal, AbortSignal.Abort, () => shutdown())
      ProcessPlus.onSigIntOnce(NodeJs.Process.process, shutdown)
      ProcessPlus.onSigTermOnce(NodeJs.Process.process, shutdown)
    } catch {
      | Js.Exn.Error(_) => ()
    }
  }
  let abortController = AbortController.make()
  let afterShutdown = ref(() => ())
  let runningWatcher = ref(Promise.resolve())
  let stopWatching = async () => {
    AbortController.abort(abortController, afterShutdown.contents)
    await runningWatcher.contents
  }
  let pendingShutdown = Promise.make((asd, _) => {
    afterShutdown := asd
  })
  runningWatcher := Promise.make((resolve, reject) => {
    runWatcher(AbortController.signal(abortController))
    ->Promise.catch(err => {
      Option.mapOr(subscription.contents, Promise.resolve(), s => s.unsubscribe())->ignore
      reject(err)->Promise.resolve
    })
    ->Promise.then(() => pendingShutdown)
    ->Promise.finally(() => {
      resolve()
    })->ignore
  })
  { stopWatching, runningWatcher: runningWatcher.contents }
}
