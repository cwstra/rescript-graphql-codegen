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
      documents: "src/operations/*.graphql",
      plugins: ["../operations/src/Index.gitignored.mjs"],
    },
  },
};

export default config;
