open Graphql
open GraphqlCodegen

type config = {
  extension?: string,
  cwd?: string,
}

module SchemaTypesSource = {
  @unboxed
  type t =
    | String(string)
    | ImportSource({path: string, namespace?: string, identifiers?: array<string>})
}

type documentImportResolverOptions = {
  baseDir: string,
  generateFilePath: string => string,
  schemaTypesSource: SchemaTypesSource.t,
  typesImport: bool,
}

module FragmentRegistry = {
  exception Unknown_type(string)
  exception Duplicate_names(array<string>)

  type fragmentImport =
    | Document(string)
    | ConcreteType(string)
    | AbstractTypeImpl({name: string, concreteType: string})
  type fragment = {
    filePath: string,
    onType: string,
    node: AST.FragmentDefinitionNode.t,
    imports: array<fragmentImport>,
  }
  type t = Dict.t<fragment>

  let build = ({generateFilePath}, {documents}: Preset.presetFnArgs<_>, schemaObject) => {
    let getFragmentImports = (possibleTypes, name) => {
      let shared = Document(name)
      switch possibleTypes {
      | [] => [shared]
      | [_] => [shared, ConcreteType(name)]
      | ts =>
        Array.concat(
          [shared],
          Array.map(ts, concreteType => AbstractTypeImpl({name, concreteType})),
        )
      }
    }
    let (duplicates, registry) = Array.reduce(documents, ([], Dict.make()), (
      (duplicateNames, registry),
      document,
    ) => {
      let fragments = document.document.definitions->Array.filterMap(d =>
        switch d {
        | FragmentDefinition({
            loc,
            name,
            variableDefinitions,
            typeCondition,
            directives,
            selectionSet,
          }) =>
          AST.FragmentDefinitionNode.FragmentDefinition({
            loc,
            name,
            variableDefinitions,
            typeCondition,
            directives,
            selectionSet,
          })->Some
        | _ => None
        }
      )
      Array.reduce(fragments, (duplicateNames, registry), (
        (duplicateNames, registry),
        fragment,
      ) => {
        open AST
        let typeName =
          fragment->FragmentDefinitionNode.typeCondition->NamedTypeNode.name->NameNode.value
        let fragmentName = fragment->FragmentDefinitionNode.name->NameNode.value
        let possibleTypes = switch Schema.getType(schemaObject, typeName)->Option.map(
          Schema.Named.parse,
        ) {
        | None =>
          raise(Unknown_type(`Fragment ${fragmentName} is set on non-existing type "${typeName}"`))
        | Some(Scalar(_) | Enum(_)) => []
        | Some(Object(o)) => [o->Schema.Object.name]
        | Some(Interface(i)) =>
          Schema.getPossibleTypes(schemaObject, Schema.Interface.toAbstract(i))->Array.map(
            Schema.Object.name,
          )
        | Some(Union(i)) =>
          Schema.getPossibleTypes(schemaObject, Schema.Union.toAbstract(i))->Array.map(
            Schema.Object.name,
          )
        }
        let filePath = document.location->generateFilePath
        let imports = getFragmentImports(possibleTypes, fragmentName)
        (
          Array.concat(
            duplicateNames,
            Dict.get(registry, fragmentName)
            ->Option.filter(
              f => {
                open FragmentDefinitionNode
                print(f.node) != print(fragment)
              },
            )
            ->Option.mapOr([], _ => [fragmentName]),
          ),
          Dict.put(
            registry,
            fragmentName,
            {
              filePath,
              imports,
              onType: fragment
              ->FragmentDefinitionNode.typeCondition
              ->NamedTypeNode.name
              ->NameNode.value,
              node: fragment,
            },
          ),
        )
      })
    })
    switch duplicates {
    | [] => registry
    | names => raise(Duplicate_names(names))
    }
  }
}

let extractExternalFragmentsInUse = (
  documentNode: AST.DocumentNode.t,
  registry: FragmentRegistry.t,
): Dict.t<int> => {
  open AST
  let ignored =
    documentNode.definitions
    ->Array.filterMap(d =>
      switch d {
      | FragmentDefinition(f) => Some(f.name->NameNode.value)
      | _ => None
      }
    )
    ->Set.fromArray
  let rec extract = (selections, result, level) =>
    switch selections {
    | SelectionSetNode.Field(f) =>
      Option.mapOr(f.selectionSet, result, (SelectionSet(s)) =>
        Array.reduce(s.selections, result, (acc, s) => extract(s, acc, level))
      )
    | InlineFragment(i) =>
      i.selectionSet
      ->SelectionSetNode.selections
      ->Array.reduce(result, (acc, s) => extract(s, acc, level))
    | FragmentSpread(f) =>
      let fragmentName = f.name->NameNode.value
      switch (Set.has(ignored, fragmentName), Dict.get(result, fragmentName)) {
      | (true, _) => result
      | (_, Some(currentLevel)) if level >= currentLevel => result
      | (_, None) | (_, Some(_)) =>
        let updated = Dict.put(result, fragmentName, level)
        Dict.get(registry, fragmentName)->Option.mapOr(updated, r =>
          r.node
          ->FragmentDefinitionNode.selectionSet
          ->SelectionSetNode.selections
          ->Array.reduce(updated, (acc, s) => extract(s, acc, level + 1))
        )
      }
    }
  documentNode.definitions->Array.reduce(Dict.make(), (acc, d) =>
    switch d {
    | FragmentDefinition(f) => f.selectionSet->SelectionSetNode.selections
    | OperationDefinition(f) => f.selectionSet->SelectionSetNode.selections
    | _ => []
    }->Array.reduce(acc, (acc, s) => extract(s, acc, 0))
  )
}

type resolvedFragment = {
  name: string,
  onType: string,
  node: AST.FragmentDefinitionNode.t,
  isExternal: bool,
  importFrom?: string,
  level: int,
}
type importSource<'identifier> = {
  path: string,
  namespace?: string,
  identifiers: array<'identifier>,
}
type importDeclaration<'identifier> = {
  baseDir: string,
  baseOutputDir: string,
  outputPath: string,
  importSource: importSource<'identifier>,
  typesImport: bool,
}

let buildFragmentResolver = (
  collectorOptions: documentImportResolverOptions,
  presetOptions: Preset.presetFnArgs<_>,
  schemaObject: Schema.t,
  dedupeFragments,
) => {
  let registry = FragmentRegistry.build(collectorOptions, presetOptions, schemaObject)
  let {baseOutputDir} = presetOptions
  let {baseDir, typesImport} = collectorOptions
  (generatedFilePath: string, documentFileContent: AST.DocumentNode.t) => {
    let (externalFragments, fragmentFileImports) = Dict.toArray(
      extractExternalFragmentsInUse(documentFileContent, registry),
    )->Array.reduce(([], Dict.make()), (acc, (fragmentName, level)) => {
      Dict.get(registry, fragmentName)->Option.mapOr(acc, fragment => {
        let (externalFragments, fragmentFileImports) = acc
        (
          Array.concat(
            externalFragments,
            [
              {
                level,
                isExternal: true,
                name: fragmentName,
                onType: fragment.onType,
                node: fragment.node,
              },
            ],
          ),
          if (
            fragment.filePath !== generatedFilePath &&
              (level == 0 ||
                (dedupeFragments &&
                switch documentFileContent.definitions->Array.get(0) {
                | Some(OperationDefinition(_)) | Some(FragmentDefinition(_)) => true
                | _ => false
                }))
          ) {
            Dict.update(
              fragmentFileImports,
              fragment.filePath,
              Option.mapOr(_, fragment.imports, a => Array.concat(fragment.imports, a)),
            )
          } else {
            fragmentFileImports
          },
        )
      })
    })
    (
      externalFragments,
      Dict.toArray(fragmentFileImports)->Array.map(((fragmentFilePath, identifiers)) => {
        baseDir,
        baseOutputDir,
        outputPath: generatedFilePath,
        importSource: {
          path: fragmentFilePath,
          identifiers,
        },
        typesImport,
      }),
    )
  }
}

let needsScalarImport = (definitions: array<AST.DefinitionNode.t>, schema: Schema.t) => {
  open AST
  let rec hasFieldSelection = (s) => 
    switch s {
    | SelectionSetNode.Field({name}) if NameNode.value(name)->String.startsWith("__") => false
    | Field({selectionSet}) => 
      Array.some(selectionSet -> SelectionSetNode.selections, hasFieldSelection)
    | Field(_) => true
    | InlineFragment(i) =>
      Array.some(i.selectionSet -> SelectionSetNode.selections, hasFieldSelection)
    // Can skip checking this;
    // in practice, we pass all relevant fragments in the definition
    | FragmentSpread(f) => false
    }
  definitions
  ->Array.flatMap(d =>
    switch d {
    | OperationDefinition({selectionSet})
    | FragmentDefinition({selectionSet}) => 
      SelectionSetNode.selections(selectionSet)
    | _ => []
    }
  )
  ->Array.some(hasFieldSelection)
}

type documentImport

let resolveDocumentImports = (
  presetOptions: Preset.presetFnArgs<_>,
  schemaObject: Schema.t,
  importResolverOptions: documentImportResolverOptions,
  ~dedupeFragments=false,
) => {
  let resolveFragments = buildFragmentResolver(
    importResolverOptions,
    presetOptions,
    schemaObject,
    dedupeFragments,
  )
  let {baseOutputDir, documents} = presetOptions
  let {generateFilePath, schemaTypesSource, baseDir, typesImport} = importResolverOptions
  documents->Result.traverse(documentFile =>
    documentFile.location
    ->Result.Ok
    ->Result.map(documentLocation => {
      let generatedFilePath = generateFilePath(documentLocation)
      let (externalFragments, fragmentImports) = resolveFragments(
        generatedFilePath,
        documentFile.document,
      )
      // TODO?: auto-open?
      //let definitions =
      //  Array.concat(
      //    documentFile.document.definitions, 
      //    Array.map(externalFragments, ({node: f}) => {
      //      AST.ExecutableDefinitionNode.fromFragmentDefinition(f)
      //      -> AST.DefinitionNode.fromExecutableDefinition
      //  }))
      //let importStatements =
      //  if needsScalarImport(definitions, schemaObject) {
      //    []
      //  } else {
      //    []
      //  }
    })
  )
}

let default: Preset.outputPreset<config, _, _, _, _> = {
  buildGeneratesSection: async options => {
    let schema = Option.getOr(
      options.schemaAst,
      Preset.buildASTSchema(options.schema, ~options=options.config),
    )
    let baseDir = Option.getOr(
      options.presetConfig.cwd,
      {
        open NodeJs.Process
        cwd(process)
      },
    )
    let extension = Option.getOr(options.presetConfig.extension, ".generated.res")
    let folder = None//options.presetConfig.folder
    let importAllFragmentsFrom = None
    let baseTypesPath = None
    let isAbsolute = false // baseTypesPath.startsWith("~")
    let pluginMap = options.pluginMap

    let generateFilePath = location => {
      let parsedLocation = NodeJs.Path.parse(location)
      [[parsedLocation.dir], Option.toArray(folder), [String.concat(parsedLocation.name, extension)]]
      -> Array.flat
      -> NodeJs.Path.join
    }

    options.documents
    ->Array.map(document => {
      {Preset.filename: generateFilePath(document.location),
       plugins: options.plugins,
       pluginMap: options.pluginMap,
       pluginContext: options.pluginContext,
       schema: options.schema,
       schemaAst: schema,
       documents: [document],
       config: options.config}
    })
  },
}
