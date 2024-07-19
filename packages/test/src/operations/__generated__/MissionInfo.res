let gql = GraphqlTag.gql
module MissionInfo = {
  let document = gql`
    fragment MissionInfo on CapsuleMission {
      flight
      name
      __typename
    }
  `
  type t = {
    flight: null<GraphqlBase.Scalars.Int.t>,
    name: null<GraphqlBase.Scalars.String.t>,
  }
}
include MissionInfo
