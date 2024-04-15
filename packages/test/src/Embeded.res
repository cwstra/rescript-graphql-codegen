module Capsule = %generated.graphql(`
fragment MissionInfo on CapsuleMission {
  flight
  name
}
query Capsule(
  $id: ID!
){
  capsule(id: $id) {
    id
    landings
    missions {
      ...MissionInfo
    }
    original_launch
    reuse_count
    status
    type
  }
}
`)
