import type { CodegenConfig } from "@graphql-codegen/cli";

const schema = "src/schema.graphql"

const config: CodegenConfig = {
  pluginLoader: (mod) =>
    mod.includes("../") ? import(mod) : require(mod),
  generates: {
    "src/GraphqlBase__Types.res": {
      schema,
      plugins: ["../base-types/src/Index.mjs"],
      config: {
        //globalNamespace: true,
        scalarModule: "GraphqlBase__Scalars",
      },
    },
    "src/operations": {
      preset: "near-operation-file",
      presetConfig: {
        extension: ".gen.res",
        baseTypesPath: ".",
      },
      config: {
        baseTypesModule: "GraphqlBase.Types",
        globalNamespace: true,
        scalarModule: "GraphqlBase.Scalars",
      },
      schema,
      documents: "src/operations/*.graphql",
      plugins: ["../operations/src/Index.mjs"],
    },
  },
};

export default config;
