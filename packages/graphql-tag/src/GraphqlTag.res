@unboxed
type input = Document(Graphql.AST.DocumentNode.t)

@module("graphql-tag") @taggedTemplate
external gql: (array<string>, array<input>) => Graphql.AST.DocumentNode.t = "gql"
