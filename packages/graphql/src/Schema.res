type schemaType<'def, 'ext> = {
  name: string,
  description: null<string>,
  astNode: null<'def>,
  extensionASTNodes: null<array<'ext>>,
}

type scalarType = schemaType<AST.ScalarTypeDefinitionNode.t, AST.ScalarTypeExtensionNode.t>
type objectType = schemaType<AST.ObjectTypeDefinitionNode.t, AST.ObjectTypeExtensionNode.t>
type interfaceType = schemaType<AST.InterfaceTypeDefinitionNode.t, AST.InterfaceTypeExtensionNode.t>
type unionType = schemaType<AST.UnionTypeDefinitionNode.t, AST.UnionTypeExtensionNode.t>
type enumType = schemaType<AST.EnumTypeDefinitionNode.t, AST.EnumTypeExtensionNode.t>
type inputObjectType = schemaType<
  AST.InputObjectTypeDefinitionNode.t,
  AST.InputObjectTypeExtensionNode.t,
>

type marks = NullMark | NonNullMark | ListMark

type listType<'t> = {ofType: 't}
type nonNullType<'t> = {ofType: 't}

module List = {
  let ofType = (l: listType<_>) => l.ofType
}

module NonNull = {
  let ofType = (nn: nonNullType<_>) => nn.ofType
}

module UnionMembers = {
  type scalar = Scalar(scalarType)
  type object = Object(objectType)
  type interface = Interface(interfaceType)
  type union = Union(unionType)
  type enum = Enum(enumType)
  type inputObject = InputObject(inputObjectType)
}

module Named = {
  type t
  type parsed =
    | ...UnionMembers.scalar
    | ...UnionMembers.object
    | ...UnionMembers.interface
    | ...UnionMembers.union
    | ...UnionMembers.enum
    | ...UnionMembers.inputObject
  @module("./graphql_facade")
  external parse: t => parsed = "wrapClassType"
}

module ValidForTypeCondition = {
  type t =
    | ...UnionMembers.object
    | ...UnionMembers.interface
    | ...UnionMembers.union
  let fromNamed = named =>
    switch named {
    | Named.Object(o) => Some(Object(o))
    | Interface(i) => Some(Interface(i))
    | Union(u) => Some(Union(u))
    | Scalar(_) | Enum(_) | InputObject(_) => None
    }
  let name = t =>
    switch t {
    | Object(o) => o.name
    | Interface(i) => i.name
    | Union(u) => u.name
    }
}

module ValidForField = {
  type t =
    | ...UnionMembers.object
    | ...UnionMembers.interface
  let fromNamed = named =>
    switch named {
    | Named.Object(o) => Some(Object(o))
    | Interface(i) => Some(Interface(i))
    | Union(_) | Scalar(_) | Enum(_) | InputObject(_) => None
    }
  let fromValidForTypeCondition = typeCond =>
    switch typeCond {
    | ValidForTypeCondition.Object(o) => Some(Object(o))
    | Interface(o) => Some(Interface(o))
    | Union(_) => None
    }
}

module Abstract = {
  type t
  type parsed =
    | ...UnionMembers.interface
    | ...UnionMembers.union
  @module("./graphql_facade")
  external parse: t => parsed = "wrapClassType"
}

module Input = {
  type t
  type t_nn
  type parsed =
    | ...UnionMembers.scalar
    | ...UnionMembers.enum
    | ...UnionMembers.inputObject
    | List(listType<t>)
    | NonNull(nonNullType<t_nn>)
  type parsed_nn =
    | ...UnionMembers.scalar
    | ...UnionMembers.enum
    | ...UnionMembers.inputObject
    | List(listType<t>)
  @module("./graphql_facade")
  external parse: t => parsed = "wrapClassType"
  @module("./graphql_facade")
  external parse_nn: t_nn => parsed_nn = "wrapClassType"
}

module Output = {
  type t
  type t_nn
  type parsed =
    | ...UnionMembers.scalar
    | ...UnionMembers.object
    | ...UnionMembers.interface
    | ...UnionMembers.union
    | ...UnionMembers.enum
    | List(listType<t>)
    | NonNull(nonNullType<t_nn>)
  type parsed_nn =
    | ...UnionMembers.scalar
    | ...UnionMembers.object
    | ...UnionMembers.interface
    | ...UnionMembers.union
    | ...UnionMembers.enum
    | List(listType<t>)
  @module("./graphql_facade")
  external parse: t => parsed = "wrapClassType"
  @module("./graphql_facade")
  external parse_nn: t_nn => parsed_nn = "wrapClassType"
  let traverse = (
    base,
    ~onScalar,
    ~onObject,
    ~onInterface,
    ~onUnion,
    ~onEnum,
    ~onList=r => r,
    ~onNull=r => r,
    ~onNonNull=r => r,
  ) => {
    let rec down = (t, mods) => {
      switch parse(t) {
      | Scalar(s) => (onScalar(s), list{NullMark, ...mods})
      | Object(o) => (onObject(o), list{NullMark, ...mods})
      | Interface(i) => (onInterface(i), list{NullMark, ...mods})
      | Union(o) => (onUnion(o), list{NullMark, ...mods})
      | Enum(o) => (onEnum(o), list{NullMark, ...mods})
      | List(l) => down(List.ofType(l), list{ListMark, NullMark, ...mods})
      | NonNull(nn) =>
        switch NonNull.ofType(nn)->parse_nn {
        | Scalar(s) => (onScalar(s), list{NonNullMark, ...mods})
        | Object(s) => (onObject(s), list{NonNullMark, ...mods})
        | Interface(s) => (onInterface(s), list{NonNullMark, ...mods})
        | Union(s) => (onUnion(s), list{NonNullMark, ...mods})
        | Enum(s) => (onEnum(s), list{NonNullMark, ...mods})
        | List(l) => down(List.ofType(l), list{ListMark, NonNullMark, ...mods})
        }
      }
    }
    let rec up = ((base, tags)) =>
      switch tags {
      | list{} => base
      | list{NullMark, ...rst} => up((onNull(base), rst))
      | list{NonNullMark, ...rst} => up((onNonNull(base), rst))
      | list{ListMark, ...rst} => up((onList(base), rst))
      }
    up(down(base, list{}))
  }
}

module Argument = {
  type t = {
    name: string,
    description: null<string>,
    @as("type")
    type_: Input.t,
    defaultValue: unknown,
    astNode: null<AST.InputValueDefinitionNode.t>,
  }
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let type_ = t => t.type_
  let defaultValue = t => t.defaultValue
  let astNode = t => Null.toOption(t.astNode)
}

module Field = {
  type t = {
    name: string,
    description: null<string>,
    @as("type")
    type_: Output.t,
    args: array<Argument.t>,
    isDeprecated?: bool,
    deprecationReason: nullable<string>,
    astNode: nullable<AST.FieldDefinitionNode.t>,
  }
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let type_ = t => t.type_
  let args = t => t.args
  let isDeprecated = t => t.isDeprecated
  let deprecationReason = t => Nullable.toOption(t.deprecationReason)
  let astNode = t => Nullable.toOption(t.astNode)
}

module Directive = {
  type location =
    | QUERY
    | MUTATION
    | SUBSCRIPTION
    | FIELD
    | FRAGMENT_DEFINITION
    | FRAGMENT_SPREAD
    | INLINE_FRAGMENT
    | VARIABLE_DEFINITION
    | SCHEMA
    | SCALAR
    | OBJECT
    | FIELD_DEFINITION
    | ARGUMENT_DEFINITION
    | INTERFACE
    | UNION
    | ENUM
    | ENUM_VALUE
    | INPUT_OBJECT
    | INPUT_FIELD_DEFINITION
  type t = {
    name: string,
    description: null<string>,
    locations: array<location>,
    isRepeatable: bool,
    args: array<Argument.t>,
    astNode: null<AST.DirectiveDefinitionNode.t>,
  }
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let locations = t => t.locations
  let isRepeatable = t => t.isRepeatable
  let args = t => t.args
  let astNode = t => Null.toOption(t.astNode)
}

module Scalar = {
  type t = scalarType
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let astNode = t => Null.toOption(t.astNode)
  let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)
  let print = (t, prefix) => `${prefix}.${name(t)}.t`
}

module Object = {
  type t = objectType
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let astNode = t => Null.toOption(t.astNode)
  let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)
  @send external getFields: t => Dict.t<Field.t> = "getFields"
  @send external getInterfaces: t => array<interfaceType> = "getInterfaces"
}

module Interface = {
  type t = interfaceType
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let astNode = t => Null.toOption(t.astNode)
  let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)
  @send external getFields: t => Dict.t<Field.t> = "getFields"
  external toAbstract: t => Abstract.t = "%identity"
}

module Union = {
  type t = unionType
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let astNode = t => Null.toOption(t.astNode)
  let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)
  @send external getTypes: t => array<objectType> = "getTypes"
  external toAbstract: t => Abstract.t = "%identity"
}

module EnumValue = {
  type t = {
    name: string,
    description: null<string>,
    value: string,
    isDeprecated?: bool,
    deprecationReason: null<string>,
    astNode: nullable<AST.EnumValueDefinitionNode.t>,
  }
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let value = t => t.value
  let isDeprecated = t => t.isDeprecated
  let deprecationReason = t => Null.toOption(t.deprecationReason)
  let astNode = t => Nullable.toOption(t.astNode)
}

module Enum = {
  type t = enumType
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let astNode = t => Null.toOption(t.astNode)
  let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)
  @send external getValues: t => array<EnumValue.t> = "getValues"
  @send external rawGetValue: (t, string) => null<EnumValue.t> = "getValue"
  let getValue = (t, s) => Null.toOption(rawGetValue(t, s))
  let print = (t, prefix) => `${prefix}.${name(t)}.t`
}

module InputField = {
  type t = {
    name: string,
    description: nullable<string>,
    @as("type")
    type_: Input.t,
    defaultValue: unknown,
    astNode: nullable<AST.InputValueDefinitionNode.t>,
  }
  let name = t => t.name
  let description = t => Nullable.toOption(t.description)
  let type_ = t => t.type_
  let defaultValue = t => t.defaultValue
  let astNode = t => Nullable.toOption(t.astNode)
}

module InputObject = {
  type t = inputObjectType
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let astNode = t => Null.toOption(t.astNode)
  let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)
  @send external getFields: t => Dict.t<InputField.t> = "getFields"
}

type t = {
  astNode: null<AST.SchemaDefinitionNode.t>,
  extensionASTNodes: null<array<AST.SchemaExtensionNode.t>>,
}

let astNode = t => Null.toOption(t.astNode)
let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)

@send @return(nullable) external getQueryType: t => option<Object.t> = "getQueryType"
@send @return(nullable) external getMutationType: t => option<Object.t> = "getMutationType"
@send @return(nullable) external getSubscriptionType: t => option<Object.t> = "getSubscriptionType"
@send external getTypeMap: t => Dict.t<Named.t> = "getTypeMap"
@send @return(nullable) external getType: (t, string) => option<Named.t> = "getType"
@send external getPossibleTypes: (t, Abstract.t) => array<Object.t> = "getPossibleTypes"
@send external isPossibleType: (t, Abstract.t, Object.t) => bool = "isPossibleType"
@send external getDirectives: t => array<Directive.t> = "getDirectives"
@send @return(nullable) external getDirective: (t, string) => option<Directive.t> = "getDirectives"
