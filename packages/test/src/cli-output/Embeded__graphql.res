// @sourceHash 83236d0e882a14516cbfe1fdbfd0c4b4

module M1 = {
  module MissionInfo = {
    let document = `
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
  module Capsule = {
    let document = `
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
    `
    type variables = {
      id: GraphqlBase.Scalars.Id.t
    }
    type t_capsule_missions = {
      flight: null<GraphqlBase.Scalars.Int.t>,
      name: null<GraphqlBase.Scalars.String.t>,
    }
    type t_capsule = {
      id: null<GraphqlBase.Scalars.Id.t>,
      landings: null<GraphqlBase.Scalars.Int.t>,
      missions: null<array<null<t_capsule_missions>>>,
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
  
}