# Rescript Graphql Codegen
This monorepo contains packages for a few purposes, in varying states of completion:
## Mostly done
- `core-plus`: Extensions around [rescript-core](https://github.com/rescript-association/rescript-core).
- `graphql`: Rescript bindings (and light wrappers) around the [graphql javascript library](https://github.com/graphql/graphql-js).
- `graphql-codegen`: Rescript bindings for writing [graphql-codegen](https://github.com/dotansimha/graphql-code-generator) plugins in rescript
- `test`: Runs generated codegen plugins
## WiP
- `operations`: Baseline Rescript codegen plugin. Generates variable and output types.
## TODO
- `near-re-operation-file`: Planned output preset; the `near-operation-file` preset automatic generates Typescript imports, which need to be prevented with certain specific values in the `presetConfig`.Ideally, this would be a very similar equivalent that requires no special config.
