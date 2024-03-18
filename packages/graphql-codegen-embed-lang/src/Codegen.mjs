// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Js_exn from "../../../node_modules/rescript/lib/es6/js_exn.js";
import * as Nodefs from "node:fs";
import * as Process from "process";
import Debounce from "debounce";
import * as Nodepath from "node:path";
import * as Core__Option from "../../../node_modules/@rescript/core/src/Core__Option.mjs";
import * as WrapperMjs from "./wrapper.mjs";
import * as Core__Promise from "../../../node_modules/@rescript/core/src/Core__Promise.mjs";
import * as Caml_js_exceptions from "../../../node_modules/rescript/lib/es6/caml_js_exceptions.js";
import * as OptionPlus$GraphqlCodegenOperations from "./OptionPlus.mjs";

function filePathMatchesPatterns(prim0, prim1) {
  return WrapperMjs.testPattern(prim0, prim1);
}

var SchemaPatterns = {
  filePathMatchesPatterns: filePathMatchesPatterns
};

function getGeneratesEntry(prim) {
  return WrapperMjs.getGeneratesEntry(prim);
}

function getSchemaPatterns(prim) {
  return WrapperMjs.getSchemaPatterns(prim);
}

var CodegenConfig = {
  getGeneratesEntry: getGeneratesEntry,
  getSchemaPatterns: getSchemaPatterns
};

function getCodegenConfig(prim) {
  return WrapperMjs.getCodegenConfig(prim);
}

async function getConfig(configFilePath) {
  var match = OptionPlus$GraphqlCodegenOperations.getOrPanic(await WrapperMjs.getCodegenConfig(configFilePath), "Codegen config not found");
  var mainConfig = match[1];
  var generatesEntry = OptionPlus$GraphqlCodegenOperations.getOrPanic(WrapperMjs.getGeneratesEntry(mainConfig), "Missing ppxGenerates property in codegen config");
  return [
          {
            mainConfig: mainConfig,
            generatesEntry: generatesEntry,
            schemaPatterns: WrapperMjs.getSchemaPatterns(mainConfig)
          },
          match[0]
        ];
}

function run(prim0, prim1, prim2) {
  return WrapperMjs.run(prim0, prim1, prim2);
}

function getPathBase(prim) {
  return WrapperMjs.getPathBase(prim);
}

var re = new RegExp("\\\\", "g");

function systemPathToNixPath(__x) {
  return __x.replace(re, "/");
}

var re$1 = new RegExp("/", "g");

function nixPathToSystemPath(__x) {
  return __x.replace(re$1, Nodepath.sep);
}

function headTail(arr) {
  return Core__Option.map(arr[0], (function (h) {
                return [
                        h,
                        arr.slice(1)
                      ];
              }));
}

function takeWhileWithIndex(arr, pred) {
  var end = arr.findIndex(function (e, i) {
        return !pred(e, i);
      });
  if (end !== -1) {
    return arr.slice(0, end);
  } else {
    return arr;
  }
}

function trace(t) {
  console.log(t);
  return t;
}

function longestCommonPrefix(paths) {
  var match = headTail(paths);
  if (match === undefined) {
    return "";
  }
  var tail = match[1];
  var head = match[0];
  if (tail.length === 0) {
    return head;
  }
  var splitTail = tail.map(function (p) {
        return p.split(Nodepath.sep);
      });
  return takeWhileWithIndex(head.split(Nodepath.sep), (function (h, i) {
                  return splitTail.every(function (tail) {
                              return Core__Option.mapOr(tail[i], false, (function (t) {
                                            return t === h;
                                          }));
                            });
                })).join(Nodepath.sep);
}

function getCwd() {
  return Process.cwd();
}

async function findHighestCommonDirectory(files) {
  var longestCommonPrefix$1 = longestCommonPrefix(files.map(function (f) {
                  if (Nodepath.isAbsolute(f)) {
                    return f;
                  } else {
                    return Nodepath.resolve(f);
                  }
                }).map(systemPathToNixPath).map(getPathBase).map(nixPathToSystemPath));
  try {
    await Nodefs.promises.access(longestCommonPrefix$1);
    return longestCommonPrefix$1;
  }
  catch (raw_exn){
    var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
    if (exn.RE_EXN_ID === Js_exn.$$Error) {
      return Process.cwd();
    }
    throw exn;
  }
}

function getParcel(prim) {
  return WrapperMjs.getParcel();
}

var $$AbortSignal = {};

var $$AbortController = {};

var ProcessPlus = {};

function createWatcher(mainConfigPath, outDir, configRef, runGeneration) {
  console.log("mainConfigPath", mainConfigPath);
  var shouldRebuild = function (absolutePath) {
    var relativePath = Nodepath.relative(Process.cwd(), absolutePath);
    var match = configRef.contents.schemaPatterns;
    if (WrapperMjs.testPattern(relativePath, match.negated)) {
      return false;
    } else {
      return WrapperMjs.testPattern(relativePath, match.affirmative);
    }
  };
  var subscription = {
    contents: undefined
  };
  var runWatcher = async function (abortSignal) {
    try {
      var parcelWatcher = await WrapperMjs.getParcel();
      var isShutdown = {
        contents: false
      };
      var debouncedExec = Debounce((function () {
              if (!isShutdown.contents) {
                runGeneration();
                return ;
              }
              
            }), 100);
      var makeSubscription = function (hcd) {
        var ignored = [
          "**/.git/**",
          Nodepath.relative(hcd, Nodepath.resolve(Process.cwd(), outDir))
        ];
        return parcelWatcher.subscribe(hcd, (async function (param, events) {
                      await Promise.all(events.map(async function (param) {
                                var path = param.path;
                                if (!shouldRebuild(path)) {
                                  return ;
                                }
                                if (param.type === "update" && mainConfigPath === path) {
                                  var match = await getConfig(mainConfigPath);
                                  var newConfig = match[0];
                                  configRef.contents = newConfig;
                                  var newHCD = await findHighestCommonDirectory([mainConfigPath].concat(newConfig.schemaPatterns.affirmative));
                                  if (hcd !== newHCD) {
                                    await Core__Option.mapOr(subscription.contents, Promise.resolve(), (function (s) {
                                            return s.unsubscribe();
                                          }));
                                    subscription.contents = await makeSubscription(newHCD);
                                  }
                                  
                                }
                                return debouncedExec();
                              }));
                    }), {
                    ignore: ignored
                  });
      };
      subscription.contents = await makeSubscription(await findHighestCommonDirectory([mainConfigPath].concat(configRef.contents.schemaPatterns.affirmative)));
      var shutdown = function () {
        isShutdown.contents = true;
        Core__Option.mapOr(subscription.contents, Promise.resolve(), (function (s) {
                return s.unsubscribe();
              }));
      };
      abortSignal.addEventListener("abort", (function () {
              shutdown();
            }));
      Process.once("SIGINT", shutdown);
      Process.once("SIGTERM", shutdown);
      return ;
    }
    catch (raw_exn){
      var exn = Caml_js_exceptions.internalToOCamlException(raw_exn);
      if (exn.RE_EXN_ID === Js_exn.$$Error) {
        return ;
      }
      throw exn;
    }
  };
  var abortController = new AbortController();
  var afterShutdown = {
    contents: (function () {
        
      })
  };
  var runningWatcher = {
    contents: Promise.resolve()
  };
  var stopWatching = async function () {
    abortController.abort(afterShutdown.contents);
    return await runningWatcher.contents;
  };
  var pendingShutdown = new Promise((function (asd, param) {
          afterShutdown.contents = asd;
        }));
  runningWatcher.contents = new Promise((function (resolve, reject) {
          Core__Promise.$$catch(runWatcher(abortController.signal), (function (err) {
                      Core__Option.mapOr(subscription.contents, Promise.resolve(), (function (s) {
                              return s.unsubscribe();
                            }));
                      return Promise.resolve(reject(err));
                    })).then(function () {
                  return pendingShutdown;
                }).finally(function () {
                resolve();
              });
        }));
  return {
          stopWatching: stopWatching,
          runningWatcher: runningWatcher.contents
        };
}

export {
  SchemaPatterns ,
  CodegenConfig ,
  getCodegenConfig ,
  getConfig ,
  run ,
  getPathBase ,
  systemPathToNixPath ,
  nixPathToSystemPath ,
  headTail ,
  takeWhileWithIndex ,
  trace ,
  longestCommonPrefix ,
  getCwd ,
  findHighestCommonDirectory ,
  getParcel ,
  $$AbortSignal ,
  $$AbortController ,
  ProcessPlus ,
  createWatcher ,
}
/* re Not a pure module */
