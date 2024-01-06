module Capsule = {
  type t_capsule_missions = {
    flight: null<GraphqlBase.Scalars.Int.t>,
    name: null<GraphqlBase.Scalars.String.t>,
  }
  type t_capsule = {
    id: null<GraphqlBase.Scalars.ID.t>,
    landings: null<GraphqlBase.Scalars.Int.t>,
    missions: null<array<null<t_capsule_missions>>>,
    original_launch: null<GraphqlBase.Scalars.Date.t>,
    reuse_count: null<GraphqlBase.Scalars.Int.t>,
    status: null<GraphqlBase.Scalars.String.t>,
    type: null<GraphqlBase.Scalars.String.t>,
  }
  type t = {
    capsule: null<t_capsule>,
  }
}
