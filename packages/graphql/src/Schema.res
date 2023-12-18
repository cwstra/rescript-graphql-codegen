type schemaType<'def, 'ext> = {
    name: string,
    description: null<string>,
    astNode: null<'def>,
    extensionASTNodes: null<array<'ext>>
}

type scalarType = schemaType<AST.scalarTypeDefinitionNode, AST.scalarTypeExtensionNode>
type objectType = schemaType<AST.objectTypeDefinitionNode, AST.objectTypeExtensionNode>
type interfaceType = schemaType<AST.interfaceTypeDefinitionNode, AST.interfaceTypeExtensionNode>
type unionType = schemaType<AST.unionTypeDefinitionNode, AST.unionTypeExtensionNode>
type enumType = schemaType<AST.enumTypeDefinitionNode, AST.enumTypeExtensionNode>
type inputObjectType = schemaType<AST.inputObjectTypeDefinitionNode, AST.inputObjectTypeExtensionNode>

type listType<'t>
type nonNullType<'t>

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
    |...UnionMembers.scalar
    |...UnionMembers.object
    |...UnionMembers.interface
    |...UnionMembers.union
    |...UnionMembers.enum
  @module("./graphql_facade")
  external parse: t => parsed = "wrapClassType"
}

module Abstract = {
  type t
  type parsed =
    |...UnionMembers.interface
    |...UnionMembers.union
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
}

module Argument = {
  type t = {
    name: string,
    description: null<string>,
    @as("type")
    type_: Input.t,
    defaultValue: unknown,
    astNode: null<AST.inputValueDefinitionNode>
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
    type_:  Output.t,
    args: array<Argument.t>,
    isDeprecated?: bool,
    deprecationReason: nullable<string>,
    astNode: nullable<AST.fieldDefinitionNode>,
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
    astNode: null<AST.directiveDefinitionNode>
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
}

module Union = {
  type t = unionType
  let name = t => t.name
  let description = t => Null.toOption(t.description)
  let astNode = t => Null.toOption(t.astNode)
  let extensionASTNodes = t => Null.toOption(t.extensionASTNodes)
  @send external getTypes: t => array<objectType> = "getTypes"
}

module EnumValue = {
  type t = {
    name: string,
    description: null<string>,
    value: unknown,
    isDeprecated?: bool,
    deprecationReason: null<string>,
    astNode: nullable<AST.enumValueDefinitionNode>
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
}

module InputField = {
  type t = {
    name: string,
    description: nullable<string>,
    @as("type")
    type_: Input.t,
    defaultValue: unknown,
    astNode: nullable<AST.inputValueDefinitionNode>
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
  astNode: null<AST.schemaDefinitionNode>,
  extensionASTNodes: null<array<AST.schemaExtensionNode>>
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