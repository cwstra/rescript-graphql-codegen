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
    {generateFilePath}: documentImportResolverOptions,
    {documents, config}: Preset.presetFnArgs<_>,
    schemaObject: Schema.t
  ) =>  {
    let getFragmentImports = (possibleTypes, name): array<fragmentImport> => {
      let shared = Document(name)
      switch possibleTypes {
        | [] => [shared]
        | [t] => [shared, ConcreteType(name)]
        | ts => Array.concat(
          [shared], 
          Array.map(ts, concreteType => AbstractTypeImpl({name, concreteType}))
        )
      }
    }
    Array.reduce(documents, Dict.make(), (registry: t, document) => {
      let fragments =
        document.document.definitions
        -> Array.filterMap((d) => switch d {
        | FragmentDefinition({loc, name, variableDefinitions, typeCondition, directives, selectionSet}) as value => 
          AST.FragmentDefinitionNode.FragmentDefinition({loc, name, variableDefinitions, typeCondition, directives, selectionSet})
          -> Some
        | _ => None
        })
      let res =
        Array.map(fragments, (FragmentDefinition(f)) => {
          let typeName = f.typeCondition -> AST.NamedTypeNode.name -> AST.NameNode.value
          let possibleTypes = switch Schema.getType(schemaObject, typeName)->Option.map(Schema.Named.parse) {
            | None => raise(Unknown_type(`Fragment ${f.name -> Option.mapOr("<unknown>",AST.NameNode.value)} is set on non-existing type "${typeName}"`))
            | Some(Scalar(_) | Enum(_)) => []
            | Some(Object(o)) => [o->Schema.Object.name]
            | Some(Interface(i)) => Schema.getPossibleTypes(schemaObject, Schema.Interface.toAbstract(i))->Array.map(Schema.Object.name)
            | Some(Union(i)) => Schema.getPossibleTypes(schemaObject, Schema.Union.toAbstract(i))->Array.map(Schema.Object.name)
          }
        })
      registry
    })
  }
}


let buildFragmentResolver = (
  collectorOptions: documentImportResolverOptions,
  presetOptions: Preset.presetFnArgs<_>,
  schemaObject: Schema.t,
  dedupeFragments
) => {
  let registry = FragmentRegistry.build(collectorOptions, presetOptions, schemaObject)
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
