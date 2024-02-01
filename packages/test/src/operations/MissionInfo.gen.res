module MissionInfo = {
  let document = `
    fragment MissionInfo on CapsuleMission {
      flight
      name
      __typename
    }
  `
  let variables = {
  }
  type t = {
    flight: null<GraphqlBase.Scalars.Int.t>,
    name: null<GraphqlBase.Scalars.String.t>,
  }
}
