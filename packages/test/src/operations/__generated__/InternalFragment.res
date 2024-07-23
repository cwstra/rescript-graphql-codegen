let gql = GraphqlTag.gql
module Internal = {
  let document = gql`
    fragment Internal on Capsule {
      id
      landings
      original_launch
      reuse_count
      status
      type
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
module InternalFragmentQuery = {
  type variables = {
    id: GraphqlBase.Scalars.Id.t,
  }
  let document = gql`
    query InternalFragmentQuery($id: ID!) {
      capsule(id: $id) {
        ...Internal
        __typename
      }
    }
    ${GraphqlTag.Document(Internal.document)}
  `
  type t = {
    capsule: null<Internal.t>,
  }
}
include InternalFragmentQuery
