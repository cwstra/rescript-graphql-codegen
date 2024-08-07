import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  pluginLoader: (mod) =>
    mod.includes("../") ? import(mod) : require(mod),
  schema: "src/schema.graphql",
  config: {
    ppxGenerates: {
      plugins: ["../operations/src/Index.gitignored.mjs"],
      config: {
        baseTypesModule: "GraphqlBase.Types",
        globalNamespace: true,
        scalarModule: "GraphqlBase.Scalars",
      }
    },
  },
  generates: {
    "src/GraphqlBase__Types.res": {
      plugins: ["../base-types/src/Index.gitignored.mjs"],
      config: {
        //globalNamespace: true,
        scalarModule: "GraphqlBase__Scalars",
        //optionalInputTypes: "unwrapped",
      },
    },
    "src/operations": {
      preset: "near-operation-file",
      presetConfig: {
        extension: ".res",
        baseTypesPath: ".",
        folder: "__generated__"
      },
      config: {
        baseTypesModule: "GraphqlBase.Types",
        globalNamespace: true,
        scalarModule: "GraphqlBase.Scalars",
        //optionalVariables: "wrapped",
        //optionalOutputs: "unwrapped",
      },
      documents: "src/operations/*.graphql",
      plugins: ["../operations/src/Index.gitignored.mjs"],
    },
  },
};

export default config;
