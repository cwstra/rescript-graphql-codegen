@unboxed
type jsonPath =
  | String(string)
  | Number(int)

type t = {
  name: string,
  message: string,
  stack?: string,
  locations: option<array<Language.sourceLocation>>,
  path: option<array<jsonPath>>,
  nodes: option<array<AST.ASTNode.t>>,
  source: option<Language.source>,
  positions: option<array<int>>,
  originalError: Js.Exn.t
}
