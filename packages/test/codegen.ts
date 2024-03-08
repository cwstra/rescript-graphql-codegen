import type {CodegenConfig} from '@graphql-codegen/cli'

const config: CodegenConfig = {
  pluginLoader: (mod) => mod.includes('@re-graphql-codegen') ? import(mod) : require(mod),
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
	  "../base-types/src/Index.mjs",
	  "../operations/src/Index.mjs"
	]
    }
  }
}

export default config
