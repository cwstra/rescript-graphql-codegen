open Graphql
open GraphqlCodegen

type config = {
  extension?: string,
  cwd?: string,
  folder?: string,
}

module SchemaTypesSource = {
  @unboxed
  type t =
    | String(string)
    | ImportSource({
      path: string,
      namespace?: string,
      identifiers?: array<string>
    })
}

type documentImportResolverOptions = {
  baseDir: string,
  generateFilePath: (string) => string,
  schemaTypesSource: SchemaTypesSource.t,
  typesImport: bool
}

module FragmentRegistry = {
  exception Unknown_type(string)
  exception Duplicate_names(array<string>)

  type fragmentImport = 
    | Document(string)
    | ConcreteType(string)
    | AbstractTypeImpl({
      name: string,
      concreteType: string
    })
  type fragment = {
    filePath: string,
    onType: string,
    node: AST.FragmentDefinitionNode.t,
    imports: array<fragmentImport>
  }
  type t = Dict.t<fragment>

  let build = (
    {generateFilePath},
    {documents}: Preset.presetFnArgs<_>,
    schemaObject
  ) =>  {
    let getFragmentImports = (possibleTypes, name) => {
      let shared = Document(name)
      switch possibleTypes {
        | [] => [shared]
        | [_] => [shared, ConcreteType(name)]
        | ts => Array.concat(
          [shared], 
          Array.map(ts, concreteType => AbstractTypeImpl({name, concreteType}))
        )
      }
    }
    let (duplicates, registry) = 
      Array.reduce(documents, ([], Dict.make() ), ((duplicateNames, registry), document) => {
      let fragments =
        document.document.definitions
        -> Array.filterMap((d) => switch d {
        | FragmentDefinition({loc, name, variableDefinitions, typeCondition, directives, selectionSet}) => 
          AST.FragmentDefinitionNode.FragmentDefinition({loc, name, variableDefinitions, typeCondition, directives, selectionSet})
          -> Some
        | _ => None
        })
      Array.reduce(fragments, (duplicateNames, registry), ((duplicateNames, registry), fragment) => {
        open AST
        let typeName = fragment -> FragmentDefinitionNode.typeCondition -> NamedTypeNode.name -> NameNode.value
        let fragmentName = fragment -> FragmentDefinitionNode.name -> NameNode.value
        let possibleTypes = switch Schema.getType(schemaObject, typeName)->Option.map(Schema.Named.parse) {
          | None => raise(Unknown_type(`Fragment ${fragmentName} is set on non-existing type "${typeName}"`))
          | Some(Scalar(_) | Enum(_)) => []
          | Some(Object(o)) => [o->Schema.Object.name]
          | Some(Interface(i)) => Schema.getPossibleTypes(schemaObject, Schema.Interface.toAbstract(i))->Array.map(Schema.Object.name)
          | Some(Union(i)) => Schema.getPossibleTypes(schemaObject, Schema.Union.toAbstract(i))->Array.map(Schema.Object.name)
        }
        let filePath = Option.getExn(document.location) -> generateFilePath 
        let imports = getFragmentImports(possibleTypes, fragmentName)
        (Array.concat(
            duplicateNames,
            Dict.get(registry, fragmentName)
            -> Option.filter(f => {
              open FragmentDefinitionNode
              print(f.node) != print(fragment)
            })
            -> Option.mapOr([], _ => [fragmentName])
          ),
          Dict.put(registry, fragmentName, {
            filePath,
            imports,
            onType: fragment -> FragmentDefinitionNode.typeCondition -> NamedTypeNode.name -> NameNode.value,
            node: fragment
          })
        )
      })
    })
    switch duplicates {
      | [] => registry
      | names => raise(Duplicate_names(names)) 
    }
  }
}

let extractExternalFragmentsInUse = (documentNode: AST.DocumentNode.t, registry: FragmentRegistry.t) => {
  open AST
  let ignored =
    documentNode.definitions
    -> Array.filterMap(d => switch d {
    | FragmentDefinition(f) => Some(f.name -> NameNode.value)
    | _ => None
    })
    -> Set.fromArray
  let rec extract = 
    (selections, result, level): Dict.t<int> => switch selections {
    | SelectionSetNode.Field(f) => 
      Option.mapOr(
        f.selectionSet, 
        result, 
        (SelectionSet(s)) => 
          Array.reduce(s.selections, result, (acc, s) => 
            extract(s, acc, level)
          )
      )
    | InlineFragment(i) => 
      i.selectionSet
      ->SelectionSetNode.selections
      ->Array.reduce(result, (acc, s) => extract(s, acc, level))
    | FragmentSpread(f) => 
      let fragmentName = f.name -> NameNode.value
      switch (Set.has(ignored, fragmentName), 
              Dict.get(result, fragmentName) 
              ) {
      | (true, _) => result
      | (_, Some(currentLevel)) if level >= currentLevel => result
      | (_, None) | (_, Some(_))  => 
        let updated = Dict.put(result, fragmentName, level)
        Dict.get(registry, fragmentName)
        -> Option.mapOr(updated, r => 
          r.node
          ->FragmentDefinitionNode.selectionSet
          ->SelectionSetNode.selections
          ->Array.reduce(updated, (acc, s) => extract(s, acc, level + 1)))
      }
    }
  let tester =
    documentNode.definitions
    -> Array.flatMap(d => switch d {
    | FragmentDefinition(f) => f.selectionSet -> SelectionSetNode.selections
    | OperationDefinition(f) => f.selectionSet -> SelectionSetNode.selections
    | _ => []
    })
    -> Array.reduce(Dict.make(), (acc, f) => extract(f, acc, 0))
}


let buildFragmentResolver = (
  collectorOptions: documentImportResolverOptions,
  presetOptions: Preset.presetFnArgs<_>,
  schemaObject: Schema.t,
  dedupeFragments
) => {
  let registry = FragmentRegistry.build(collectorOptions, presetOptions, schemaObject)
  let {baseOutputDir} = presetOptions
  let {baseDir, typesImport}  = collectorOptions
  (generatedFilePath: string, documentFileContent: AST.DocumentNode.t) => {
    let fragmentsInUse = extractExternalFragmentsInUse(documentFileContent, registry)
  }
}

let resolveDocumentImports = (
  presetOptions: Preset.presetFnArgs<_>, 
  schemaObject: Schema.t, 
  importResolverOptions: documentImportResolverOptions,
  ~dedupeFragments = false
) => {
  let resolveFragments = buildFragmentResolver(
    importResolverOptions,
    presetOptions,
    schemaObject,
    dedupeFragments
  )
}

let default: Preset.outputPreset<config, _, _, _, _> = {
  buildGeneratesSection: async options => {
    let schema = Option.getOr(
      options.schemaAst,
      Preset.buildASTSchema(options.schema, ~options=options.config),
    )
    let baseDir = Option.getOr(options.presetConfig.cwd, {
      open NodeJs.Process
      cwd(process)
    })
    let fileName = ""
    let extension = Option.getOr(options.presetConfig.extension, ".generated.res")
    let folder = options.presetConfig.folder
    let importTypesNamespace = "Types"
    let importAllFragmentsFrom = None
    let baseTypesPath = None
    // if !baseTypesPath throw error
    let isAbsolute = false // baseTypesPath.startsWith("~")
    let pluginsMap = options.pluginMap
    []
  },
}
