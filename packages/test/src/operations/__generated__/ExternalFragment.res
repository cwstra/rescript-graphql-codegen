let gql = GraphqlTag.gql
module External = {
  let document = gql`
    fragment External on Capsule {
      id
      landings
      original_launch
      reuse_count
      status
      type
      __typename
      __typename
    }
  `
  type t = {
    id: null<GraphqlBase.Scalars.Id.t>,
    landings: null<GraphqlBase.Scalars.Int.t>,
    original_launch: null<GraphqlBase.Scalars.Date.t>,
    reuse_count: null<GraphqlBase.Scalars.Int.t>,
    status: null<GraphqlBase.Scalars.String.t>,
    @as("type")
    type_: null<GraphqlBase.Scalars.String.t>,
  }
}
include External
