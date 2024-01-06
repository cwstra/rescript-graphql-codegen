module Union = {
  let document = `
    query Union {
      get_union {
        ... on MemberA {
          id
          a
          __typename
        }
        __typename
      }
    }
  `
  let variables = {
  }
  module Get_union = {
    @tag("__typename")
    type t =
      | MemberA({
        id: null<GraphqlBase.Scalars.ID.t>,
        a: null<GraphqlBase.Scalars.String.t>,
      })
      | MemberB
      | MemberC
  }
  type t_get_union = Get_union.t
  type t = {
    get_union: null<t_get_union>,
  }
}
