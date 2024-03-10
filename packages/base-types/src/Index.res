open Graphql
open GraphqlCodegen

type config = {
  scalarModule: string,
  externalFragments: array<Base.resolvedFragment>,
  nullType?: string,
  listType?: string,
}

let makePrintInputObjectType = config => {
  let {scalarModule, listType: ?rawListType, nullType: ?rawNullType} = config
  let listType = Option.getOr(rawListType, "array")
  let nullType = Option.getOr(rawNullType, "null")
  inputObject => {
    let fields = Schema.InputObject.getFields(inputObject)
    Array.concatMany(
      ["  type t = {"],
      [
        Dict.toArray(fields)->Array.flatMap(((rawKey, t)) => {
          let (key, alias) = Helpers.sanitizeFieldName(rawKey, fields)
          let rec printInput = (i, w) =>
            switch Schema.Input.parse(i) {
            | Scalar(s) => w(`${nullType}<${scalarModule}.${Schema.Scalar.name(s)->String.pascalCase}.t>`)
            | Enum(e) => w(`${nullType}<${Schema.Enum.name(e)->String.pascalCase}.t>`)
            | InputObject(io) =>
              w(`${nullType}<${Schema.InputObject.name(io)->String.pascalCase}.t>`)
            | List(l) =>
              printInput(Schema.List.ofType(l), s => w(`${nullType}<${listType}<${s}>>`))
            | NonNull(nn) =>
              switch Schema.NonNull.ofType(nn)->Schema.Input.parse_nn {
              | Scalar(s) => w(`${scalarModule}.${Schema.Scalar.name(s)->String.pascalCase}.t`)
              | Enum(e) => w(`${Schema.Enum.name(e)->String.pascalCase}.t`)
              | InputObject(io) => w(`${Schema.InputObject.name(io)->String.pascalCase}.t`)
              | List(l) => printInput(Schema.List.ofType(l), s => w(`${listType}<${s}>`))
              }
            }
          let value = printInput(Schema.InputField.type_(t), s => s)
          let mainLine = `    ${key}: ${value},`
          switch alias {
          | None => [mainLine]
          | Some(a) => [`    @as("${a}")`, mainLine]
          }
        }),
        ["  }"]
      ]
    )
}}

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
      Array.concatMany(
        [`module ${Schema.Enum.name(enum)->String.pascalCase} = {`],
        [
          ["  type t = "],
          Array.flatMap(values, v => [
            `    | @as("${Schema.EnumValue.value(v)}")`,
            `    ${Schema.EnumValue.name(v)->String.pascalCase}`,
          ]),
          ["}"],
        ],
      )->Array.joinWith("\n")
    })->Array.joinWith("\n\n")

    let inputObjectResult =
      Helpers.sortInputObjectsTopologically(inputObjects)
      ->Array.map(ior =>
        switch ior {
        | NonRec(io) => {
            Array.concatMany(
              [`module ${Schema.InputObject.name(io)->String.pascalCase} = {`],
              [
                printInputObjectType(io),
                ["}"],
              ],
            )->Array.joinWith("\n")
          }
          | Rec(cycle) => {
            Console.log2("cycle", cycle)
            Array.mapWithIndex(cycle, (io, ind) => {
              let moduleName = Schema.InputObject.name(io)->String.pascalCase
              Array.concatMany(
                [`${ind == 0 ? "module rec" : "and"} ${moduleName}: {`],
                [
                  printInputObjectType(io),
                  [`} = ${moduleName}`]
                ]
              )->Array.joinWith("\n")
            }
            )->Array.joinWith("\n\n")
          }
        }
      )
      ->Array.joinWith("\n\n")

    let res = Array.joinWith([enumResult, inputObjectResult], "\n\n")

    Plugin.PluginOutput.String(res)
  } catch {
  | e => {
      raise(e)
    }
  }
