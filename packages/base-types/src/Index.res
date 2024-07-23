open Graphql
open GraphqlCodegen

@unboxed
type optionalPropertyConfig =
  | @as("wrapped") WithWrapper
  | @as("unwrapped") WithoutWrapper

type config = {
  scalarModule: string,
  externalFragments: array<Base.resolvedFragment>,
  nullType?: string,
  listType?: string,
  optionalInputTypes?: optionalPropertyConfig,
  futureAddedValueName?: string,
  includeEnumAllValuesArray?: bool,
  appendToEnums?: string,
}

let makePrintInputObjectType = config => {
  let {scalarModule, listType: ?rawListType, nullType: ?rawNullType} = config
  let listType = Option.getOr(rawListType, "array")
  let nullType = Option.getOr(rawNullType, "null")
  let printScalar = s => `${scalarModule}.${Schema.Scalar.name(s)->String.pascalCase}.t`
  let printEnum = e => `${Schema.Enum.name(e)->String.pascalCase}.t`
  let printInputObject = io => `${Schema.InputObject.name(io)->String.pascalCase}.t`
  let rec printStep = (i: Schema.Input.parsed, w) =>
    switch i {
    | Scalar(s) => w(`${nullType}<${printScalar(s)}>`)
    | Enum(e) => w(`${nullType}<${printEnum(e)}>`)
    | InputObject(io) => w(`${nullType}<${printInputObject(io)}>`)
    | List(l) =>
      printStep(Schema.Input.parse(Schema.List.ofType(l)), s => w(`${nullType}<${listType}<${s}>>`))
    | NonNull(nn) =>
      switch Schema.NonNull.ofType(nn)->Schema.Input.parse_nn {
      | Scalar(s) => w(printScalar(s))
      | Enum(e) => w(printEnum(e))
      | InputObject(io) => w(printInputObject(io))
      | List(l) => printStep(Schema.Input.parse(Schema.List.ofType(l)), s => w(`${listType}<${s}>`))
      }
    }
  let printInput = switch config.optionalInputTypes {
  | Some(WithoutWrapper) =>
    (key, input) => {
      //`${key}?: printStep(p, s => s)`
      let value = switch Schema.Input.parse(input) {
      | Scalar(s) => printScalar(s)->Either.Left
      | Enum(e) => printEnum(e)->Either.Left
      | InputObject(io) => printInputObject(io)->Either.Left
      | List(l) =>
        printStep(Schema.Input.parse(Schema.List.ofType(l)), s => `${listType}<${s}>`)->Either.Left
      | NonNull(_) as p => printStep(p, s => s)->Either.Right
      }
      switch value {
      | Left(nullable) => `${key}?: ${nullable},`
      | Right(nonNullable) => `${key}: ${nonNullable},`
      }
    }

  | Some(WithWrapper) =>
    (key, input) => {
      let value = switch Schema.Input.parse(input) {
      | Scalar(_) as p
      | Enum(_) as p
      | InputObject(_) as p
      | List(_) as p =>
        printStep(p, s => s)->Either.Left
      | NonNull(_) as p => printStep(p, s => s)->Either.Right
      }
      switch value {
      | Left(nullable) => `${key}?: ${nullable},`
      | Right(nonNullable) => `${key}: ${nonNullable},`
      }
    }
  | None => (key, input) => `${key}: ${Schema.Input.parse(input)->printStep(s => s)},`
  }
  inputObject => {
    let fields = Schema.InputObject.getFields(inputObject)
    [
      "  type t = {",
      ...Dict.toArray(fields)->Array.flatMap(((rawKey, t)) => {
        let (key, alias) = Helpers.sanitizeFieldName(rawKey, fields)
        let mainLine = `    ${printInput(key, Schema.InputField.type_(t))}`
        switch alias {
        | None => [mainLine]
        | Some(a) => [`    @as("${a}")`, mainLine]
        }
      }),
      "  }",
    ]
  }
}

let plugin: Plugin.pluginFunction<config> = async (schema, _documents, config) =>
  try {
    // Need to have __typename for unions;
    // at least for now, just going to shove
    // that onto selection sets at the start.
    let printInputObjectType = makePrintInputObjectType(config)

    let (enums, inputObjects) =
      Schema.getTypeMap(schema)
      ->Dict.valuesToArray
      ->Array.filterMap(t =>
        switch Schema.Named.parse(t) {
        | Enum(e) => Some(Either.Left(e))
        | InputObject(io) => Some(Either.Right(io))
        | _ => None
        }
      )
      ->Either.partition

    let enumResult = Array.map(enums, enum => {
      let values = Schema.Enum.getValues(enum)
      [
        `module ${Schema.Enum.name(enum)->String.pascalCase} = {`,
        "  @unboxed",
        "  type t = ",
        ...Array.flatMap(values, v => [
          `    | @as("${Schema.EnumValue.value(v)}")`,
          `    ${Schema.EnumValue.name(v)->String.pascalCase}`,
        ]),
        ...Option.mapOr(config.futureAddedValueName, [], n => [`    | ${n}(string)`]),
        ...if config.includeEnumAllValuesArray == Some(true) {
          [
            "  let allValues = [",
            ...Array.map(values, v => `    ${Schema.EnumValue.name(v)->String.pascalCase},`),
            "  ]",
          ]
        } else {
          []
        },
        ...Option.mapOr(config.appendToEnums, [], str => [str]),
        "}",
      ]->Array.join("\n")
    })->Array.join("\n\n")

    let inputObjectResult =
      Helpers.sortInputObjectsTopologically(inputObjects)
      ->Array.map(ior =>
        switch ior {
        | NonRec(io) =>
          [
            `module ${Schema.InputObject.name(io)->String.pascalCase} = {`,
            ...printInputObjectType(io),
            "}",
          ]->Array.join("\n")
        | Rec(cycle) =>
          Array.mapWithIndex(cycle, (io, ind) => {
            let moduleName = Schema.InputObject.name(io)->String.pascalCase
            [
              `${ind == 0 ? "module rec" : "and"} ${moduleName}: {`,
              ...printInputObjectType(io),
              `} = ${moduleName}`,
            ]->Array.join("\n")
          })->Array.join("\n\n")
        }
      )
      ->Array.join("\n\n")

    let res = Array.join([enumResult, inputObjectResult], "\n\n")

    Plugin.PluginOutput.String(res)
  } catch {
  | e => raise(e)
  }
