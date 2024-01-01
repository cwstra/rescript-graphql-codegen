open Graphql
open GraphqlCodegen

type config = {scalarModule: string}

module RemainingWork = {
  open AST
  type rec inputType = 
    [ #Scalar(string) 
    | #Enum(string) 
    | #Object(Dict.t<inputType>)
    | #List(inputType)
    | #NonNull(nn_inputType)]
  and nn_inputType =
    [ #Scalar(string) 
    | #Enum(string) 
    | #Object(Dict.t<inputType>)
    | #List(inputType)]
  type gqlVariable = {
    name: string,
    type_: inputType
  }
  type gqlType = {}

  type t =
    | PrintingTypes({
        openScalars: bool,
        definitions: list<ExecutableDefinitionNode.t>,
        header: string,
        variables: list<gqlVariable>,
        types: list<gqlType>,
      })
    | PrintingVariables({
        openScalars: bool,
        definitions: list<ExecutableDefinitionNode.t>,
        header: string,
        variables: list<gqlVariable>,
      })
    | FinalizeDefinition({
        openScalars: bool,
        definitions: list<ExecutableDefinitionNode.t>,
        header: string,
      })
    | ReadyForNextDefinition({openScalars: bool, definitions: list<ExecutableDefinitionNode.t>})
    | FinalizeFile({openScalars: bool})

  // Assume sorted topologically  -> List.fromArray

  let fromDefinitions = definitions => ReadyForNextDefinition({
    openScalars: false,
    definitions: Array.toReversed(definitions)->List.fromArray,
  })

  let processTypes = (gqlType, schema) => {
    (list{}, [])
  }
  let processVariable = (gqlVariable, schema) => {
    []
  }
  let processHeader = (header, schema) => {
    []
  }
  let processDefinition = (definition, schema) => {
    let (variableDefs, selectionSet) = switch definition {
    | ExecutableDefinitionNode.OperationDefinition(o) =>
      (o.variableDefinitions, o.selectionSet)
    | FragmentDefinition(f) => 
      (f.variableDefinitions, f.selectionSet)
    }
    let parseInputType = (t: TypeNode.t) => {
    } 
    (list{}, 
    Array.map(Option.getOr(variableDefs, []), (a): gqlVariable => {
      let name: string = 
        VariableDefinitionNode.variable(a)
        ->VariableNode.name
        ->NameNode.value
      {name, type_: []}
    })
    ->List.fromArray,
    "",
    [])
  }
  let processImports = (openScalars, schema) => {
    []
  }

  let rec process = (t: t, schema: Schema.t, lines: array<string>) =>
    switch t {
    | PrintingTypes({openScalars, definitions, header, variables, types: list{}}) =>
      process(PrintingVariables({openScalars, definitions, header, variables}), schema, lines)
    | PrintingTypes({openScalars, definitions, header, variables, types: list{next, ...rest}}) => {
        let (newTypes, newLines) = processTypes(next, schema)
        process(
          PrintingTypes({
            openScalars,
            definitions,
            header,
            variables,
            types: List.concat(newTypes, rest),
          }),
          schema,
          Array.concat(newLines, lines),
        )
      }
    | PrintingVariables({openScalars, definitions, header, variables: list{}}) =>
      process(FinalizeDefinition({openScalars, definitions, header}), schema, lines)
    | PrintingVariables({openScalars, definitions, header, variables: list{next, ...rest}}) => {
        let newLines = processVariable(next, schema)
        process(
          PrintingVariables({openScalars, definitions, header, variables: rest}),
          schema,
          Array.concat(newLines, lines),
        )
      }
    | FinalizeDefinition({openScalars, definitions, header}) => {
        let newLines = processHeader(header, schema)
        process(
          ReadyForNextDefinition({openScalars, definitions}),
          schema,
          Array.concat(newLines, lines),
        )
      }
    | ReadyForNextDefinition({openScalars: s, definitions: list{}}) =>
      process(FinalizeFile({openScalars: s}), schema, lines)
    | ReadyForNextDefinition({openScalars, definitions: list{next, ...rest}}) => {
        let (types, variables, header, newLines) = processDefinition(next, schema)
        process(
          PrintingTypes({openScalars, definitions: rest, header, types, variables}),
          schema,
          Array.concat(newLines, lines),
        )
      }
    | FinalizeFile({openScalars}) => {
        let newLines = processImports(openScalars, schema)
        Array.concat(newLines, lines)
      }
    }

  /*
  let moveNextDefinition = ({openScalars, definitions, types}) =>
    Array.at(definitions, -1)->Option.map(def => {
      let types = switch def {
      | OperationDefinition(d) => []
      | FragmentDefinition(f) => []
      }
      {
        openScalars,
        definitions: Array.slice(definitions, ~start=0, ~end=-1),
        types,
      }
    })
 */
}

let plugin: Plugin.pluginFunction<config> = async (schema, documents, config) => {
  Console.log(config)

  let (fragments, operations) =
    Array.flatMap(documents, d => d.document.definitions)
    ->Array.filterMap(d =>
      switch d {
      | OperationDefinition(o) =>
        Some(
          Either.Right(
            AST.OperationDefinitionNode.OperationDefinition({
              loc: ?o.loc,
              operation: o.operation,
              name: ?o.name,
              variableDefinitions: ?o.variableDefinitions,
              directives: ?o.directives,
              selectionSet: o.selectionSet,
            }),
          ),
        )
      | FragmentDefinition(f) =>
        Some(
          Either.Left(
            AST.FragmentDefinitionNode.FragmentDefinition({
              loc: ?f.loc,
              name: f.name,
              variableDefinitions: ?f.variableDefinitions,
              typeCondition: f.typeCondition,
              directives: ?f.directives,
              selectionSet: f.selectionSet,
            }),
          ),
        )
      | _ => None
      }
    )
    ->Either.partition(f => f)

  let sorted = Array.concat(
    Helpers.sortFragmentsTopologically(fragments)->Array.map(
      AST.ExecutableDefinitionNode.fromFragmentDefinition,
    ),
    operations->Array.map(AST.ExecutableDefinitionNode.fromOperationDefinition),
  )

  let extractTypesFromDefinition = (definition: AST.ExecutableDefinitionNode.t) =>
    switch definition {
    | OperationDefinition({operation, ?name, ?variableDefinitions, selectionSet}) => []
    | FragmentDefinition(f) => []
    }

  /*
  let rec process = (work: RemainingWork.t, lines: array<string>) =>
    switch work {
    | {openScalars: true, definitions: [], types: []} =>
      Array.concat([`open ${config.scalarModule}`], Array.toReversed(lines))
    | {openScalars: false, definitions: [], types: []} => Array.toReversed(lines)
    | {openScalars, definitions, types: []} => {
        let bleh = Array.pop(definitions)
        process({openScalars, definitions, types}, lines)
      }
    }

  (definition: AST.ExecutableDefinitionNode.t, work) => {
    switch definition {
    | FragmentDefinition({name, typeCondition, selectionSet}) => {
        let fragmentType =
          Schema.getType(schema, AST.NameNode.value(name))
          ->Option.getExn
          ->Schema.Named.parse
          ->Schema.ValidForTypeCondition.fromNamed
          ->Option.getExn
      }
    | OperationDefinition(d) => []
    }
    work
  }
 */

  Console.log("\n\n\n\n\n")
  Plugin.PluginOutput.String("")
}
