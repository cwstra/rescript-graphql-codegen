open Graphql
open GraphqlCodegen

type config = {
  scalarModule: string,
  baseTypesModule: string,
  externalFragments: array<Base.resolvedFragment>,
  nullType?: string,
  listType?: string,
}

let plugin: Plugin.pluginFunction<config> = async (schema, _documents, config) =>
  try {
    // Need to have __typename for unions;
    // at least for now, just going to shove
    // that onto selection sets at the start.
    Console.log(config)
    Console.log(_documents)
    let {baseTypesModule, listType, nullType} = config

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

    let inputObjectResult = Helpers.sortInputObjectsTopologically(inputObjects)->Array.map(io => {
      let fields = Schema.InputObject.getFields(io)
      Array.concatMany(
        [`module ${Schema.InputObject.name(io)->String.pascalCase} = {`],
        [
          ["  type t = {"],
          Dict.toArray(fields)->Array.flatMap(((rawKey, t)) => {
            let (key, alias) = Helpers.sanitizeFieldName(rawKey, fields)
            let rec printInput = (i, w) =>
              switch Schema.Input.parse(i) {
              | Scalar(s) => w(`${nullType}<${baseTypesModule}.${Schema.Scalar.name(s)}.t>`)
              | Enum(e) => w(`${nullType}<${Schema.Enum.name(e)->String.pascalCase}.t>`)
              | InputObject(io) =>
                w(`${nullType}<${Schema.InputObject.name(io)->String.pascalCase}>`)
              | List(l) =>
                printInput(Schema.List.ofType(l), s => w(`${listType}<${nullType}<${s}>>`))
              | NonNull(nn) =>
                switch Schema.NonNull.ofType(nn)->Schema.Input.parse_nn {
                | Scalar(s) => w(`${baseTypesModule}.${Schema.Scalar.name(s)}.t`)
                | Enum(e) => w(`${Schema.Enum.name(e)->String.pascalCase}.t`)
                | InputObject(io) => w(`${Schema.InputObject.name(io)->String.pascalCase}`)
                | List(l) => printInput(Schema.List.ofType(l), s => w(`${listType}<${s}>`))
                }
              }
            let value = printInput(Schema.InputField.type_(t), s => s)
            let mainLine = `    ${key}: ${value},`
            switch alias {
            | None => [mainLine]
            | Some(a) => [`    | @as("${a}")`, mainLine]
            }
          }),
          ["  }", "}"],
        ],
      )->Array.joinWith("\n")
    })

    let res = ""

    Plugin.PluginOutput.String(res)
  } catch {
  | e => {
      Console.log(e)
      raise(e)
    }
  }
