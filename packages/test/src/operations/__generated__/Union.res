let gql = GraphqlTag.gql
module Union = {
  type variables = {
  
  }
  let document = gql`
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
  module Get_union = {
    @tag("__typename")
    type t =
      | MemberA({
      id: null<GraphqlBase.Scalars.Id.t>,
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
include Union
