// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Js_dict = require("rescript/lib/js/js_dict.js");
var Cli = require("@graphql-codegen/cli");

function fn(a, b) {
  return a + b | 0;
}

function run(schema, pluginName, inputSdl, filePath) {
  return Cli.generate({
              schema: schema,
              documents: inputSdl,
              generates: Js_dict.fromArray([[
                      filePath,
                      {
                        plugins: [pluginName]
                      }
                    ]])
            }, true);
}

exports.fn = fn;
exports.run = run;
/* @graphql-codegen/cli Not a pure module */
