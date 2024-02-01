type source = {
  document: Graphql.AST.DocumentNode.t,
  schema: Graphql.Schema.t,
  rawSDL?: string,
  location?: string,
}
type documentFile = {
  document: Graphql.AST.DocumentNode.t,
  schema: Graphql.Schema.t,
  rawSDL?: string,
  location: string,
}
type resolvedFragment = {
  name: string,
  onType: string,
  node: Graphql.AST.FragmentDefinitionNode.t,
  isExternal: bool,
  importFrom?: string,
  level: int,
}
