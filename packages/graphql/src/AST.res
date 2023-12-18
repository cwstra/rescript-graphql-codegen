type location = {
  start: int,
  end: int,
}

module NameNode = {
  @tag("kind")
  type t = NameNode({loc?: location, value: string})
  let loc = (NameNode(r)) => r.loc
  let value = (NameNode(r)) => r.value
}

module VariableNode = {
  @tag("kind")
  type t = Variable({loc?: location, name: NameNode.t})
}
module IntValueNode = {
  @tag("kind")
  type t = IntValue({loc?: location, value: string})
}
module FloatValueNode = {
  @tag("kind")
  type t = FloatValue({loc?: location, value: string})
}
module StringValueNode = {
  @tag("kind")
  type t = StringValue({loc?: location, value: string, block?: bool})
}
module BooleanValueNode = {
  @tag("kind")
  type t = BooleanValue({loc?: location, value: bool})
}
module NullValueNode = {
  @tag("kind")
  type t = NullValue({loc?: location})
}
module EnumValueNode = {
  @tag("kind")
  type t = EnumValue({loc?: location, value: string})
}

module ValueNode = {
  @tag("kind")
  type rec t =
    | ...VariableNode.t
    | ...IntValueNode.t
    | ...FloatValueNode.t
    | ...StringValueNode.t
    | ...BooleanValueNode.t
    | ...NullValueNode.t
    | ...EnumValueNode.t
    | ListValue({loc?: location, values: array<t>})
    | ObjectValue({loc?: location, fields: array<objectFieldNode>})
  @tag("kind") and objectFieldNode = ObjectField({loc?: location, name: NameNode.t, value: t})
}

module NamedTypeNode = {
  @tag("kind")
  type t = NamedType({loc?: location, name: NameNode.t})
  let loc = (NamedType(r)) => r.loc
  let name = (NamedType(r)) => r.name
}
module TypeNode = {
  @@warning("-30")
  @tag("kind")
  type rec t =
    | ...NamedTypeNode.t
    | ListType({
        loc?: location,
        @as("type")
        type_: t,
      })
    | NonNullType({
        loc?: location,
        @as("type")
        type_: listOrNamedTypeNode,
      })
  @tag("kind")
  and listOrNamedTypeNode =
    | ...NamedTypeNode.t
    | @as("ListType")
    NullListType({
        loc?: location,
        @as("type")
        type_: t,
      })
  @@warning("+30")
}

@unboxed
type operationTypeNode =
  | @as("query") Query
  | @as("mutation") Mutation
  | @as("subscription") Subscription

module ArgumentNode = {
  @tag("kind")
  type t = Argument({loc?: location, name: NameNode.t, value: ValueNode.t})
}
module DirectiveNode = {
  @tag("kind")
  type t = Directive({loc?: location, name: NameNode.t, arguments?: array<ArgumentNode.t>})
}
module VariableDefinitionNode = {
  @tag("kind")
  type t =
    | VariableDefinition({
        loc?: location,
        variable: VariableNode.t,
        @as("type")
        type_: TypeNode.t,
        defaultValue?: ValueNode.t,
        directives?: DirectiveNode.t,
      })
}

module SelectionSetNode = {
  @tag("kind")
  type rec selectionNode =
    | Field({
        loc?: location,
        alias?: NameNode.t,
        name: NameNode.t,
        arguments?: array<ArgumentNode.t>,
        directives?: array<DirectiveNode.t>,
        selectionSet?: t,
      })
    | FragmentSpread({loc?: location, name: NameNode.t, directives?: array<DirectiveNode.t>})
    | InlineFragment({
        loc?: location,
        typeCondition?: NamedTypeNode.t,
        directives?: array<DirectiveNode.t>,
        selectionSet: t,
      })
  @tag("kind") and t = SelectionSet({loc?: location, selections: array<selectionNode>})
}

module OperationTypeDefinitionNode = {
  @tag("kind")
  type t =
    | OperationTypeDefinition({
        loc?: location,
        operation: operationTypeNode,
        @as("type")
        type_: NamedTypeNode.t,
      })
}
module InputValueDefinitionNode = {
  @tag("kind")
  type t =
    | InputValueDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        @as("type")
        type_: TypeNode.t,
        defaultValue?: ValueNode.t,
        directives?: array<DirectiveNode.t>,
      })
}
module FieldDefinitionNode = {
  @tag("kind")
  type t =
    | FieldDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        arguments?: array<InputValueDefinitionNode.t>,
        @as("type")
        type_: TypeNode.t,
        directives?: array<DirectiveNode.t>,
      })
}
module EnumValueDefinitionNode = {
  @tag("kind")
  type t =
    | EnumValueDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
      })
}
module OperationDefinitionNode = {
  @tag("kind")
  type t =
    | OperationDefinition({
        loc?: location,
        operation: operationTypeNode,
        name?: NameNode.t,
        variableDefinitions?: array<VariableDefinitionNode.t>,
        directives?: array<DirectiveNode.t>,
        selectionSet: SelectionSetNode.t,
      })
}
module FragmentDefinitionNode = {
  @tag("kind")
  type t =
    | FragmentDefinition({
        loc?: location,
        name?: NameNode.t,
        variableDefinitions?: array<VariableDefinitionNode.t>,
        typeCondition: NamedTypeNode.t,
        directives?: array<DirectiveNode.t>,
        selectionSet: SelectionSetNode.t,
      })
}
module ExecutableDefinitionNode = {
  @tag("kind")
  type t =
    | ...OperationDefinitionNode.t
    | ...FragmentDefinitionNode.t
}
module SchemaDefinitionNode = {
  @tag("kind")
  type t =
    | SchemaDefinition({
        loc?: location,
        directives?: array<DirectiveNode.t>,
        operationTypes: array<OperationTypeDefinitionNode.t>,
      })
}
module ScalarTypeDefinitionNode = {
  @tag("kind")
  type t =
    | ScalarTypeDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
      })
}
module ObjectTypeDefinitionNode = {
  @tag("kind")
  type t =
    | ObjectTypeDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        interfaces?: array<NamedTypeNode.t>,
        directives?: array<DirectiveNode.t>,
        fields?: array<FieldDefinitionNode.t>,
      })
}
module InterfaceTypeDefinitionNode = {
  @tag("kind")
  type t =
    | InterfaceTypeDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        field?: array<FieldDefinitionNode.t>,
      })
}
module UnionTypeDefinitionNode = {
  @tag("kind")
  type t =
    | UnionTypeDefinitionNode({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives: array<DirectiveNode.t>,
        types?: array<NamedTypeNode.t>,
      })
}
module EnumTypeDefinitionNode = {
  @tag("kind")
  type t =
    | EnumTypeDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        values?: array<EnumValueDefinitionNode.t>,
      })
}
module InputObjectTypeDefinitionNode = {
  @tag("kind")
  type t =
    | InputObjectTypeDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        fields?: array<InputValueDefinitionNode.t>,
      })
}
module TypeDefinitionNode = {
  @tag("kind")
  type t =
    | ...ScalarTypeDefinitionNode.t
    | ...InterfaceTypeDefinitionNode.t
    | ...UnionTypeDefinitionNode.t
    | ...EnumTypeDefinitionNode.t
    | ...InputObjectTypeDefinitionNode.t
}
module DirectiveDefinitionNode = {
  @tag("kind")
  type t =
    | DirectiveDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        arguments: array<InputValueDefinitionNode.t>,
        repeatable: bool,
        locations: array<NameNode.t>,
      })
}
module TypeSystemDefinitionNode = {
  @tag("kind")
  type t =
    | ...SchemaDefinitionNode.t
    | ...TypeDefinitionNode.t
    | ...DirectiveDefinitionNode.t
}
module SchemaExtensionNode = {
  @tag("kind")
  type t =
    | SchemaExtension({
        loc?: location,
        directives?: array<DirectiveNode.t>,
        operationTypes?: array<OperationTypeDefinitionNode.t>,
      })
}
module ScalarTypeExtensionNode = {
  @tag("kind")
  type t =
    ScalarTypeExtension({loc?: location, name: NameNode.t, directives?: array<DirectiveNode.t>})
}
module ObjectTypeExtensionNode = {
  @tag("kind")
  type t =
    | ObjectTypeExtension({
        loc?: location,
        name: NameNode.t,
        interfaces?: array<NamedTypeNode.t>,
        directives?: array<DirectiveNode.t>,
        fields?: array<FieldDefinitionNode.t>,
      })
}
module InterfaceTypeExtensionNode = {
  @tag("kind")
  type t =
    | InterfaceTypeExtension({
        loc?: location,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        fields?: array<FieldDefinitionNode.t>,
      })
}
module UnionTypeExtensionNode = {
  @tag("kind")
  type t =
    | UnionTypeExtension({
        loc?: location,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        types?: array<NamedTypeNode.t>,
      })
}
module EnumTypeExtensionNode = {
  @tag("kind")
  type t =
    | EnumTypeExtension({
        loc?: location,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        values?: array<EnumValueDefinitionNode.t>,
      })
}
module InputObjectTypeExtensionNode = {
  @tag("kind")
  type t =
    | InputObjectTypeExtension({
        loc?: location,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        fields?: array<InputValueDefinitionNode.t>,
      })
}
module TypeExtensionNode = {
  @tag("kind")
  type t =
    | ...ScalarTypeExtensionNode.t
    | ...ObjectTypeExtensionNode.t
    | ...InterfaceTypeExtensionNode.t
    | ...UnionTypeExtensionNode.t
    | ...EnumTypeExtensionNode.t
    | ...InputObjectTypeExtensionNode.t
}
module TypeSystemExtensionNode = {
  @tag("kind")
  type t =
    | ...SchemaExtensionNode.t
    | ...TypeExtensionNode.t
}
module DefinitionNode = {
  @tag("kind")
  type t =
    | ...ExecutableDefinitionNode.t
    | ...TypeSystemDefinitionNode.t
    | ...TypeSystemExtensionNode.t
}

module DocumentNode = {
  type t = {
    loc?: location,
    definitions: array<DefinitionNode.t>,
  }
}
