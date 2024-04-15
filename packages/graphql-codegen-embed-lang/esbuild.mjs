import * as esbuild from 'esbuild'

await esbuild.build({
  entryPoints: ['src/Index.gitignored.mjs'],
  bundle: true,
  outfile: "dist/Index.js",
  platform: "node",
  external: [
    "graphql",
    "@graphql-codegen/cli",
    "@graphql-codegen/plugin-helpers",
    "micromatch",
    "chokidar"
  ],
  minify: true
})

//yarn esbuild
// peer
// --external:graphql --external:@graphql-codegen/cli
// proper
// -external:chokidar --external:fast-glob
// inferred?
// --external:micromatch
