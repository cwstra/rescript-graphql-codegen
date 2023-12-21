import type {CodegenConfig} from '@graphql-codegen/cli'

const config: CodegenConfig = {
  generates: {
    "src/operations": {
	preset: "near-operation-file",
	presetConfig: {
	  extension: ".gen.res",
	  baseTypesPath: "."
	},
	config: {
	  globalNamespace: true,
	  scalarModule: "GraphqlBase.Scalars",
	},
	schema: "src/schema.graphql",
	documents: "src/operations/*.graphql",
	plugins: [
	  "../operations/src/Index.bs.js"
	]
    }
  }
}

export default config
