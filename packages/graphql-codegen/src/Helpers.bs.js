// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var CorePlus = require("@re-graphql-codegen/core-plus/src/CorePlus.bs.js");
var AST$Graphql = require("@re-graphql-codegen/graphql/src/AST.bs.js");
var Caml_option = require("rescript/lib/js/caml_option.js");
var Schema$Graphql = require("@re-graphql-codegen/graphql/src/Schema.bs.js");
var Caml_exceptions = require("rescript/lib/js/caml_exceptions.js");

var Unknown_field = /* @__PURE__ */Caml_exceptions.create("Helpers-GraphqlCodegen.Unknown_field");

function getFieldType(baseType, fieldName) {
  var fields;
  fields = baseType.TAG === "Object" ? Schema$Graphql.$$Object.getFields(baseType._0) : Schema$Graphql.Interface.getFields(baseType._0);
  var f = fields[fieldName];
  if (f !== undefined) {
    return Schema$Graphql.Field.type_(Caml_option.valFromOption(f));
  }
  var tmp;
  tmp = baseType.TAG === "Object" ? Schema$Graphql.$$Object.name(baseType._0) : Schema$Graphql.Interface.name(baseType._0);
  throw {
        RE_EXN_ID: Unknown_field,
        _1: tmp,
        _2: fieldName,
        Error: new Error()
      };
}

var Cyclic_fragments = /* @__PURE__ */Caml_exceptions.create("Helpers-GraphqlCodegen.Cyclic_fragments");

function sortFragmentsTopologically(definitions) {
  var extractDependsFromSelections = function (_selections, _fragmentNamesOpt) {
    while(true) {
      var fragmentNamesOpt = _fragmentNamesOpt;
      var selections = _selections;
      var fragmentNames = fragmentNamesOpt !== undefined ? fragmentNamesOpt : [];
      var newFragmentNames = CorePlus.$$Array.filterMap(selections, (function (s) {
              switch (s.kind) {
                case "FragmentSpread" :
                    return AST$Graphql.NameNode.value(s.name);
                case "Field" :
                case "InlineFragment" :
                    return ;
                
              }
            }));
      var nestedSelections = selections.flatMap(function (s) {
            switch (s.kind) {
              case "Field" :
                  var selectionSet = s.selectionSet;
                  if (selectionSet !== undefined) {
                    return AST$Graphql.SelectionSetNode.selections(selectionSet);
                  } else {
                    return [];
                  }
              case "FragmentSpread" :
                  return [];
              case "InlineFragment" :
                  return AST$Graphql.SelectionSetNode.selections(s.selectionSet);
              
            }
          });
      if (nestedSelections.length === 0) {
        return fragmentNames;
      }
      _fragmentNamesOpt = fragmentNames.concat(newFragmentNames);
      _selections = nestedSelections;
      continue ;
    };
  };
  var withDepends = definitions.map(function (node) {
        return {
                name: AST$Graphql.NameNode.value(AST$Graphql.FragmentDefinitionNode.name(node)),
                node: node,
                dependsOn: extractDependsFromSelections(AST$Graphql.SelectionSetNode.selections(AST$Graphql.FragmentDefinitionNode.selectionSet(node)), undefined)
              };
      });
  if (withDepends.length !== 0) {
    var _unsortedFragments = withDepends;
    var _sortedFragmentsOpt;
    while(true) {
      var sortedFragmentsOpt = _sortedFragmentsOpt;
      var unsortedFragments = _unsortedFragments;
      var sortedFragments = sortedFragmentsOpt !== undefined ? sortedFragmentsOpt : [];
      unsortedFragments.sort(function (f1, f2) {
            return CorePlus.Ordering.compare(f1.dependsOn.length, f2.dependsOn.length);
          });
      var match = CorePlus.$$Array.takeDropWhile(unsortedFragments, (function (f) {
              return f.dependsOn.length === 0;
            }));
      var independent = match[0];
      if (independent.length !== 0) {
        var dependent = match[1];
        if (dependent.length === 0) {
          return sortedFragments.concat(independent).map(function (f) {
                      return f.node;
                    });
        }
        _sortedFragmentsOpt = sortedFragments.concat(independent);
        _unsortedFragments = dependent.map((function(independent){
            return function (fragment) {
              return {
                      name: fragment.name,
                      node: fragment.node,
                      dependsOn: fragment.dependsOn.filter(function (dependency) {
                            return independent.some(function (i) {
                                        return i.name === dependency;
                                      });
                          })
                    };
            }
            }(independent)));
        continue ;
      }
      throw {
            RE_EXN_ID: Cyclic_fragments,
            Error: new Error()
          };
    };
  } else {
    return [];
  }
}

exports.Unknown_field = Unknown_field;
exports.getFieldType = getFieldType;
exports.Cyclic_fragments = Cyclic_fragments;
exports.sortFragmentsTopologically = sortFragmentsTopologically;
/* Schema-Graphql Not a pure module */
