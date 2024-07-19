import camelcase from "camelcase"

export const pascalCase = str => camelcase(str, { pascalCase: true })
