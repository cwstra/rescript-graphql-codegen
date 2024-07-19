let gql = GraphqlTag.gql
module ExternalFragmentQuery = {
  type variables = {
    id: GraphqlBase.Scalars.Id.t
  }
  let document = gql`
    query ExternalFragmentQuery($id: ID!) {
      capsule(id: $id) {
        missions {
          flight
          name
          __typename
        }
        ...External
        __typename
      }
    }
    ${GraphqlTag.Document(ExternalFragment.External.document)}
  `
  type t_capsule_missions = {
    flight: null<GraphqlBase.Scalars.Int.t>,
    name: null<GraphqlBase.Scalars.String.t>,
  }
  type t_capsule = {
    missions: null<array<null<t_capsule_missions>>>,
    id: null<GraphqlBase.Scalars.Id.t>,
    landings: null<GraphqlBase.Scalars.Int.t>,
    original_launch: null<GraphqlBase.Scalars.Date.t>,
    reuse_count: null<GraphqlBase.Scalars.Int.t>,
    status: null<GraphqlBase.Scalars.String.t>,
    @as("type")
    type_: null<GraphqlBase.Scalars.String.t>,
  }
  type t = {
    capsule: null<t_capsule>,
  }
}
include ExternalFragmentQuery
