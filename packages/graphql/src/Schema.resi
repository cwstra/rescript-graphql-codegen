type scalarType
type objectType
type interfaceType
type unionType
type enumType
type inputObjectType

type listType<'t>
type nonNullType<'t>

module UnionMembers: {
  type scalar = Scalar(scalarType)
  type object = Object(objectType)
  type interface = Interface(interfaceType)
  type union = Union(unionType)
  type enum = Enum(enumType)
  type inputObject = InputObject(inputObjectType)
}

module Named: {
  type t
  type parsed =
    | ...UnionMembers.scalar
    | ...UnionMembers.object
    | ...UnionMembers.interface
    | ...UnionMembers.union
    | ...UnionMembers.enum
    | ...UnionMembers.inputObject
  let parse: t => parsed
}

module ValidForTypeCondition: {
  type t =
    | ...UnionMembers.object
    | ...UnionMembers.interface
    | ...UnionMembers.union
  let fromNamed: Named.parsed => option<t>
}

module ValidForField: {
  type t =
    | ...UnionMembers.object
    | ...UnionMembers.interface
  let fromNamed: Named.parsed => option<t>
}

module Abstract: {
  type t
  type parsed =
    | ...UnionMembers.interface
    | ...UnionMembers.union
}

module Input: {
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
  let parse: t => parsed
  let parse_nn: t_nn => parsed_nn
}

module Output: {
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
  let parse: t => parsed
  let parse_nn: t_nn => parsed_nn
}

module Argument: {
  type t
  let name: t => string
  let description: t => option<string>
  let type_: t => Input.t
  let defaultValue: t => unknown
  let astNode: t => option<AST.InputValueDefinitionNode.t>
}

module Field: {
  type t
  let name: t => string
  let description: t => option<string>
  let type_: t => Output.t
  let args: t => array<Argument.t>
  let isDeprecated: t => option<bool>
  let deprecationReason: t => option<string>
  let astNode: t => option<AST.FieldDefinitionNode.t>
}

module Directive: {
  type t
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
  let name: t => string
  let description: t => option<string>
  let locations: t => array<location>
  let isRepeatable: t => bool
  let args: t => array<Argument.t>
  let astNode: t => option<AST.DirectiveDefinitionNode.t>
}

module Scalar: {
  type t = scalarType
  let name: t => string
  let description: t => option<string>
  let astNode: t => option<AST.ScalarTypeDefinitionNode.t>
  let extensionASTNodes: t => option<array<AST.ScalarTypeExtensionNode.t>>
}

module Object: {
  type t = objectType
  let name: t => string
  let description: t => option<string>
  let astNode: t => option<AST.ObjectTypeDefinitionNode.t>
  let extensionASTNodes: t => option<array<AST.ObjectTypeExtensionNode.t>>
  let getFields: t => Dict.t<Field.t>
  let getInterfaces: t => array<interfaceType>
}

module Interface: {
  type t = interfaceType
  let name: t => string
  let description: t => option<string>
  let astNode: t => option<AST.InterfaceTypeDefinitionNode.t>
  let extensionASTNodes: t => option<array<AST.InterfaceTypeExtensionNode.t>>
  let getFields: t => Dict.t<Field.t>
  let toAbstract: t => Abstract.t
}

module Union: {
  type t = unionType
  let name: t => string
  let description: t => option<string>
  let astNode: t => option<AST.UnionTypeDefinitionNode.t>
  let extensionASTNodes: t => option<array<AST.UnionTypeExtensionNode.t>>
  let getTypes: t => array<objectType>
  let toAbstract: t => Abstract.t
}

module EnumValue: {
  type t
  let name: t => string
  let description: t => option<string>
  let value: t => unknown
  let isDeprecated: t => option<bool>
  let deprecationReason: t => option<string>
  let astNode: t => option<AST.EnumValueDefinitionNode.t>
}

module Enum: {
  type t = enumType
  let name: t => string
  let description: t => option<string>
  let astNode: t => option<AST.EnumTypeDefinitionNode.t>
  let extensionASTNodes: t => option<array<AST.EnumTypeExtensionNode.t>>
  let getValues: t => array<EnumValue.t>
  let getValue: (t, string) => option<EnumValue.t>
}

module InputField: {
  type t
  let name: t => string
  let description: t => option<string>
  let type_: t => Input.t
  let defaultValue: t => unknown
  let astNode: t => option<AST.InputValueDefinitionNode.t>
}

module InputObject: {
  type t = inputObjectType
  let name: t => string
  let description: t => option<string>
  let astNode: t => option<AST.InputObjectTypeDefinitionNode.t>
  let extensionASTNodes: t => option<array<AST.InputObjectTypeExtensionNode.t>>
  let getFields: t => Dict.t<InputField.t>
}

type t
let astNode: t => option<AST.SchemaDefinitionNode.t>
let extensionASTNodes: t => option<array<AST.SchemaExtensionNode.t>>
let getQueryType: t => option<Object.t>
let getMutationType: t => option<Object.t>
let getSubscriptionType: t => option<Object.t>
let getTypeMap: t => Dict.t<Named.t>
let getType: (t, string) => option<Named.t>
let getPossibleTypes: (t, Abstract.t) => array<Object.t>
let isPossibleType: (t, Abstract.t, Object.t) => bool
let getDirectives: t => array<Directive.t>
let getDirective: (t, string) => option<Directive.t>
