open Graphql
open GraphqlCodegen

type config = {
  scalarModule: string,
  baseTypesModule: string,
  nullType?: string,
  listType?: string,
}

let config = {
  scalarModule: "GraphqlBase.Scalars",
  baseTypesModule: "GraphqlBase.Gen",
}

let plugin: Plugin.pluginFunction<config> = async (schema, documents, config) => 
  try {
    // Need to have __typename for unions;
    // at least for now, just going to shove
    // that onto seleciton sets at the start.
    let (fragments, operations) =
      Array.flatMap(documents, d =>  AST.addTypenameToDocument(d.document).definitions)
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
    let fragmentLookup =
      Array.map(fragments, f => (
        AST.FragmentDefinitionNode.name(f)->AST.NameNode.value,
        f,
      ))->Dict.fromArray

    let sorted = Array.concat(
      Helpers.sortFragmentsTopologically(fragments)->Array.map(
        AST.ExecutableDefinitionNode.fromFragmentDefinition,
      ),
      operations->Array.map(AST.ExecutableDefinitionNode.fromOperationDefinition),
    )
    let init = WorkItem.fromDefinitions(sorted)


    let res = WorkItem.process(
      ~steps=init,
      ~fragments=fragmentLookup,
      ~schema,
      ~baseTypesModule=config.baseTypesModule,
      ~scalarModule=config.scalarModule,
      ~listType=Option.getOr(config.listType, "array"),
      ~nullType=Option.getOr(config.nullType, "null")
    )

    /*
    Console.log(res)

    Console.log("\n\n\n\n\n")
    Plugin.PluginOutput.String("Hello")
    */
    Plugin.PluginOutput.String(res)
  } catch {
  | e => {
    Console.log(e)
    raise(e)
  }}
