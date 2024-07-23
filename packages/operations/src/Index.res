open Graphql
open GraphqlCodegen

exception Fragment_name_not_ending_in_fragment(string)

type config = {
  scalarModule: string,
  baseTypesModule: string,
  gqlTagModule?: string,
  externalFragments?: array<Base.resolvedFragment>,
  fragmentImports?: array<Base.FragmentImport.t>,
  optionalVariables?: WorkItem.optionalPropertyConfig,
  optionalOutputs?: WorkItem.optionalPropertyConfig,
  nullType?: string,
  listType?: string,
  fragmentWrapper?: string,
  appendToFragments?: string,
  appendToQueries?: string,
  appendToMutations?: string,
  appendToSubscriptions?: string,
}

let plugin: Plugin.pluginFunction<config> = async (schema, documents, config) =>
  try {
    // Need to have __typename for unions;
    // at least for now, just going to shove
    // that onto selection sets at the start.
    let (internalFragments, operations) =
      Array.flatMap(documents, d =>
        switch AST.addTypenameToDocument(d.document) {
        | Document({definitions}) => definitions
        }
      )
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
      ->Either.partition

    let withoutFragmentSuffix = str => {
      let suffix = "Fragment"
      if String.endsWith(str, suffix) {
        String.slice(str, ~start=0, ~end=String.length(str)-String.length(suffix))
      } else {
        raise(Fragment_name_not_ending_in_fragment(str))
      }
    }
    let externalFragmentImportLookup =
      Option.getOr(config.fragmentImports, [])
      ->Array.filterMap(fi => {
        let moduleName = NodeJs.Path.basenameExt(fi.importSource.path, ".res")
        Array.findMap(fi.importSource.identifiers, i =>
          switch i {
          | Type({name})  => Some(name)
          | _ => None
          }
        )->Option.map(withoutFragmentSuffix)->Option.map(fragmentName => (fragmentName, `${moduleName}.${fragmentName}`))
      })
      ->Dict.fromArray

    let allFragments = [
      ...config.externalFragments
      ->Option.getOr([])
      ->Array.map(e => {
        WorkItem.definition: e.node,
        externalName: Dict.get(
          externalFragmentImportLookup,
          AST.FragmentDefinitionNode.name(e.node)->AST.NameNode.value,
        ),
      }),
      ...Array.map(internalFragments, e => {
        WorkItem.definition: e,
        externalName: None,
      }),
    ]

    let fragmentLookup =
      Array.map(allFragments, f => (
        AST.FragmentDefinitionNode.name(f.definition)->AST.NameNode.value,
        f,
      ))->Dict.fromArray

    let sorted = [
      ...Array.map(allFragments, f => f.definition)
      ->Helpers.sortFragmentsTopologically
      ->Array.filterMap(f =>
        switch Dict.get(
          externalFragmentImportLookup,
          AST.FragmentDefinitionNode.name(f)->AST.NameNode.value,
        ) {
        | Some(_) => None
        | None => AST.ExecutableDefinitionNode.fromFragmentDefinition(f)->Some
        }
      ),
      ...operations->Array.map(AST.ExecutableDefinitionNode.fromOperationDefinition),
    ]
    let gqlTagModule = Option.getOr(config.gqlTagModule, "GraphqlTag")
    let init = WorkItem.fromDefinitions(sorted, gqlTagModule)

    let res = WorkItem.process(
      ~steps=init,
      ~fragments=fragmentLookup,
      ~schema,
      ~baseTypesModule=config.baseTypesModule,
      ~scalarModule=config.scalarModule,
      ~fragmentWrapper=Option.getOr(config.fragmentWrapper, `${gqlTagModule}.Document`),
      ~listType=Option.getOr(config.listType, "array"),
      ~nullType=Option.getOr(config.nullType, "null"),
      ~optionalVariables=config.optionalVariables,
      ~optionalOutputs=config.optionalOutputs,
      ~appendToFragments=config.appendToFragments,
      ~appendToQueries=config.appendToQueries,
      ~appendToMutations=config.appendToMutations,
      ~appendToSubscriptions=config.appendToSubscriptions,
    )

    Plugin.PluginOutput.String(res)
  } catch {
  | e => {
      Console.log(e)
      raise(e)
    }
  }
