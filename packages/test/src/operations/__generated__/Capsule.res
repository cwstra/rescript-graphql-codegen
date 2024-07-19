let gql = GraphqlTag.gql
module Capsule = {
  type variables = {
    id: GraphqlBase.Scalars.Id.t
  }
  let document = gql`
    query Capsule($id: ID!) {
      capsule(id: $id) {
        id
        landings
        missions {
          ...MissionInfo
          __typename
        }
        original_launch
        reuse_count
        status
        type
        __typename
      }
    }
    ${GraphqlTag.Document(MissionInfo.MissionInfo.document)}
  `
  type t_capsule = {
    id: null<GraphqlBase.Scalars.Id.t>,
    landings: null<GraphqlBase.Scalars.Int.t>,
    missions: null<array<null<MissionInfo.MissionInfo.t>>>,
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
include Capsule
