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
module FragmentImport = {
  @tag("kind")
  type identifier =
    | @as("type") Type({name: string})
    | @as("document") Document({name: string})
  type importSource = {
    path: string,
    identifiers: array<identifier>,
  }
  type t = {importSource: importSource}
}
