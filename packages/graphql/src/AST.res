type location = {
  start: int,
  end: int,
}

module NameNode = {
  @tag("kind")
  type t = Name({loc?: location, value: string})
  let loc = (Name(r)) => r.loc
  let value = (Name(r)) => r.value
  @module("graphql")
  external print: t => string = "print"
}

module VariableNode = {
  @tag("kind")
  type t = Variable({loc?: location, name: NameNode.t})
  let loc = (Variable(r)) => r.loc
  let name = (Variable(r)) => r.name
  @module("graphql")
  external print: t => string = "print"
}
module IntValueNode = {
  @tag("kind")
  type t = IntValue({loc?: location, value: string})
  let loc = (IntValue(r)) => r.loc
  let value = (IntValue(r)) => r.value
  @module("graphql")
  external print: t => string = "print"
}
module FloatValueNode = {
  @tag("kind")
  type t = FloatValue({loc?: location, value: string})
  let loc = (FloatValue(r)) => r.loc
  let value = (FloatValue(r)) => r.value
  @module("graphql")
  external print: t => string = "print"
}
module StringValueNode = {
  @tag("kind")
  type t = StringValue({loc?: location, value: string, block?: bool})
  let loc = (StringValue(r)) => r.loc
  let value = (StringValue(r)) => r.value
  let block = (StringValue(r)) => r.block
  @module("graphql")
  external print: t => string = "print"
}
module BooleanValueNode = {
  @tag("kind")
  type t = BooleanValue({loc?: location, value: bool})
  let loc = (BooleanValue(r)) => r.loc
  let value = (BooleanValue(r)) => r.value
  @module("graphql")
  external print: t => string = "print"
}
module NullValueNode = {
  @tag("kind")
  type t = NullValue({loc?: location})
  let loc = (NullValue(r)) => r.loc
  @module("graphql")
  external print: t => string = "print"
}
module EnumValueNode = {
  @tag("kind")
  type t = EnumValue({loc?: location, value: string})
  let loc = (EnumValue(r)) => r.loc
  let value = (EnumValue(r)) => r.value
  @module("graphql")
  external print: t => string = "print"
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
  @module("graphql")
  external print: t => string = "print"
}

module NamedTypeNode = {
  @tag("kind")
  type t = NamedType({loc?: location, name: NameNode.t})
  let loc = (NamedType(r)) => r.loc
  let name = (NamedType(r)) => r.name
  @module("graphql")
  external print: t => string = "print"
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
  @module("graphql")
  external print: t => string = "print"
}

@unboxed
type operationTypeNode =
  | @as("query") Query
  | @as("mutation") Mutation
  | @as("subscription") Subscription

module ArgumentNode = {
  @tag("kind")
  type t = Argument({loc?: location, name: NameNode.t, value: ValueNode.t})
  let loc = (Argument(a)) => a.loc
  let name = (Argument(a)) => a.name
  let value = (Argument(a)) => a.value
  @module("graphql")
  external print: t => string = "print"
}
module DirectiveNode = {
  @tag("kind")
  type t = Directive({loc?: location, name: NameNode.t, arguments?: array<ArgumentNode.t>})
  let loc = (Directive(a)) => a.loc
  let name = (Directive(a)) => a.name
  let arguments = (Directive(a)) => a.arguments
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (VariableDefinition(a)) => a.loc
  let variable = (VariableDefinition(a)) => a.variable
  let type_ = (VariableDefinition(a)) => a.type_
  let defaultValue = (VariableDefinition(a)) => a.defaultValue
  let directives = (VariableDefinition(a)) => a.directives
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (SelectionSet(s)) => s.loc
  let selections = (SelectionSet(s)) => s.selections
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (OperationTypeDefinition(o)) => o.loc
  let operation = (OperationTypeDefinition(o)) => o.operation
  let type_ = (OperationTypeDefinition(o)) => o.type_
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (InputValueDefinition(i)) => i.loc
  let description = (InputValueDefinition(i)) => i.description
  let name = (InputValueDefinition(i)) => i.name
  let type_ = (InputValueDefinition(i)) => i.type_
  let defaultValue = (InputValueDefinition(i)) => i.defaultValue
  let directives = (InputValueDefinition(i)) => i.directives
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (FieldDefinition(i)) => i.loc
  let description = (FieldDefinition(i)) => i.description
  let name = (FieldDefinition(i)) => i.name
  let arguments = (FieldDefinition(i)) => i.arguments
  let type_ = (FieldDefinition(i)) => i.type_
  let directives = (FieldDefinition(i)) => i.directives
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (EnumValueDefinition(i)) => i.loc
  let description = (EnumValueDefinition(i)) => i.description
  let name = (EnumValueDefinition(i)) => i.name
  let directives = (EnumValueDefinition(i)) => i.directives
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (OperationDefinition(i)) => i.loc
  let operation = (OperationDefinition(i)) => i.operation
  let name = (OperationDefinition(i)) => i.name
  let variableDefinitions = (OperationDefinition(i)) => i.variableDefinitions
  let directives = (OperationDefinition(i)) => i.directives
  let selectionSet = (OperationDefinition(i)) => i.selectionSet
  @module("graphql")
  external print: t => string = "print"
}
module FragmentDefinitionNode = {
  @tag("kind")
  type t =
    | FragmentDefinition({
        loc?: location,
        name: NameNode.t,
        variableDefinitions?: array<VariableDefinitionNode.t>,
        typeCondition: NamedTypeNode.t,
        directives?: array<DirectiveNode.t>,
        selectionSet: SelectionSetNode.t,
      })
  let loc = (FragmentDefinition(f)) => f.loc
  let name = (FragmentDefinition(f)) => f.name
  let variableDefinitions = (FragmentDefinition(f)) => f.variableDefinitions
  let typeCondition = (FragmentDefinition(f)) => f.typeCondition
  let directives = (FragmentDefinition(f)) => f.directives
  let selectionSet = (FragmentDefinition(f)) => f.selectionSet
  @module("graphql")
  external print: t => string = "print"
}
module ExecutableDefinitionNode = {
  @tag("kind")
  type t =
    | ...OperationDefinitionNode.t
    | ...FragmentDefinitionNode.t
  @module("graphql")
  external print: t => string = "print"
  external fromFragmentDefinition: (FragmentDefinitionNode.t) => t = "%identity"
  external fromOperationDefinition: (OperationDefinitionNode.t) => t = "%identity"
}
module SchemaDefinitionNode = {
  @tag("kind")
  type t =
    | SchemaDefinition({
        loc?: location,
        directives?: array<DirectiveNode.t>,
        operationTypes: array<OperationTypeDefinitionNode.t>,
      })
  let loc = (SchemaDefinition(f)) => f.loc
  let directives = (SchemaDefinition(f)) => f.directives
  let operationTypes = (SchemaDefinition(f)) => f.operationTypes
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (ScalarTypeDefinition(f)) => f.loc
  let description = (ScalarTypeDefinition(f)) => f.description
  let name = (ScalarTypeDefinition(f)) => f.name
  let directives = (ScalarTypeDefinition(f)) => f.directives
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (ObjectTypeDefinition(f)) => f.loc
  let description = (ObjectTypeDefinition(f)) => f.description
  let name = (ObjectTypeDefinition(f)) => f.name
  let interfaces = (ObjectTypeDefinition(f)) => f.interfaces
  let directives = (ObjectTypeDefinition(f)) => f.directives
  let fields = (ObjectTypeDefinition(f)) => f.fields
  @module("graphql")
  external print: t => string = "print"
}
module InterfaceTypeDefinitionNode = {
  @tag("kind")
  type t =
    | InterfaceTypeDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives?: array<DirectiveNode.t>,
        fields?: array<FieldDefinitionNode.t>,
      })
  let loc = (InterfaceTypeDefinition(f)) => f.loc
  let description = (InterfaceTypeDefinition(f)) => f.description
  let name = (InterfaceTypeDefinition(f)) => f.name
  let directives = (InterfaceTypeDefinition(f)) => f.directives
  let fields = (InterfaceTypeDefinition(f)) => f.fields
  @module("graphql")
  external print: t => string = "print"
}
module UnionTypeDefinitionNode = {
  @tag("kind")
  type t =
    | UnionTypeDefinition({
        loc?: location,
        description?: StringValueNode.t,
        name: NameNode.t,
        directives: array<DirectiveNode.t>,
        types?: array<NamedTypeNode.t>,
      })
  let loc = (UnionTypeDefinition(f)) => f.loc
  let description = (UnionTypeDefinition(f)) => f.description
  let name = (UnionTypeDefinition(f)) => f.name
  let directives = (UnionTypeDefinition(f)) => f.directives
  let types = (UnionTypeDefinition(f)) => f.types
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (EnumTypeDefinition(f)) => f.loc
  let description = (EnumTypeDefinition(f)) => f.description
  let name = (EnumTypeDefinition(f)) => f.name
  let directives = (EnumTypeDefinition(f)) => f.directives
  let types = (EnumTypeDefinition(f)) => f.values
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (InputObjectTypeDefinition(f)) => f.loc
  let description = (InputObjectTypeDefinition(f)) => f.description
  let name = (InputObjectTypeDefinition(f)) => f.name
  let directives = (InputObjectTypeDefinition(f)) => f.directives
  let fields = (InputObjectTypeDefinition(f)) => f.fields
  @module("graphql")
  external print: t => string = "print"
}
module TypeDefinitionNode = {
  @tag("kind")
  type t =
    | ...ScalarTypeDefinitionNode.t
    | ...InterfaceTypeDefinitionNode.t
    | ...UnionTypeDefinitionNode.t
    | ...EnumTypeDefinitionNode.t
    | ...InputObjectTypeDefinitionNode.t
  @module("graphql")
  external print: t => string = "print"
  external fromScalarTypeDefinition: (ScalarTypeDefinitionNode.t) => t = "%identity"
  external fromInterfaceTypeDefinition: (InterfaceTypeDefinitionNode.t) => t = "%identity"
  external fromUnionTypeDefinition: (UnionTypeDefinitionNode.t) => t = "%identity"
  external fromEnumTypeDefinition: (EnumTypeDefinitionNode.t) => t = "%identity"
  external fromInputObjectTypeDefinition: (InputObjectTypeDefinitionNode.t) => t = "%identity"
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
  let loc = (DirectiveDefinition(f)) => f.loc
  let description = (DirectiveDefinition(f)) => f.description
  let name = (DirectiveDefinition(f)) => f.name
  let arguments = (DirectiveDefinition(f)) => f.arguments
  let repeatable = (DirectiveDefinition(f)) => f.repeatable
  let locations = (DirectiveDefinition(f)) => f.locations
  @module("graphql")
  external print: t => string = "print"
}
module TypeSystemDefinitionNode = {
  @tag("kind")
  type t =
    | ...SchemaDefinitionNode.t
    | ...TypeDefinitionNode.t
    | ...DirectiveDefinitionNode.t
  @module("graphql")
  external print: t => string = "print"
  external fromSchemaDefinition: (SchemaDefinitionNode.t) => t = "%identity"
  external fromTypeDefinition: (TypeDefinitionNode.t) => t = "%identity"
  external fromDirectiveDefinitionNode: (DirectiveDefinitionNode.t) => t = "%identity"
}
module SchemaExtensionNode = {
  @tag("kind")
  type t =
    | SchemaExtension({
        loc?: location,
        directives?: array<DirectiveNode.t>,
        operationTypes?: array<OperationTypeDefinitionNode.t>,
      })
  let loc = (SchemaExtension(f)) => f.loc
  let directives = (SchemaExtension(f)) => f.directives
  let operationTypes = (SchemaExtension(f)) => f.operationTypes
  @module("graphql")
  external print: t => string = "print"
}
module ScalarTypeExtensionNode = {
  @tag("kind")
  type t =
    ScalarTypeExtension({loc?: location, name: NameNode.t, directives?: array<DirectiveNode.t>})
  let loc = (ScalarTypeExtension(f)) => f.loc
  let name = (ScalarTypeExtension(f)) => f.name
  let directives = (ScalarTypeExtension(f)) => f.directives
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (ObjectTypeExtension(f)) => f.loc
  let name = (ObjectTypeExtension(f)) => f.name
  let interfaces = (ObjectTypeExtension(f)) => f.interfaces
  let directives = (ObjectTypeExtension(f)) => f.directives
  let fields = (ObjectTypeExtension(f)) => f.fields
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (InterfaceTypeExtension(f)) => f.loc
  let name = (InterfaceTypeExtension(f)) => f.name
  let directives = (InterfaceTypeExtension(f)) => f.directives
  let fields = (InterfaceTypeExtension(f)) => f.fields
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (UnionTypeExtension(f)) => f.loc
  let name = (UnionTypeExtension(f)) => f.name
  let directives = (UnionTypeExtension(f)) => f.directives
  let types = (UnionTypeExtension(f)) => f.types
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (EnumTypeExtension(f)) => f.loc
  let name = (EnumTypeExtension(f)) => f.name
  let directives = (EnumTypeExtension(f)) => f.directives
  let values = (EnumTypeExtension(f)) => f.values
  @module("graphql")
  external print: t => string = "print"
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
  let loc = (InputObjectTypeExtension(f)) => f.loc
  let name = (InputObjectTypeExtension(f)) => f.name
  let directives = (InputObjectTypeExtension(f)) => f.directives
  let fields = (InputObjectTypeExtension(f)) => f.fields
  @module("graphql")
  external print: t => string = "print"
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
  @module("graphql")
  external print: t => string = "print"
  external fromScalarTypeExtension: (ScalarTypeExtensionNode.t) => t = "%identity"
  external fromObjectTypeExtension: (ObjectTypeExtensionNode.t) => t = "%identity"
  external fromInterfaceTypeExtension: (InterfaceTypeExtensionNode.t) => t = "%identity"
  external fromUnionTypeExtension: (UnionTypeExtensionNode.t) => t = "%identity"
  external fromEnumTypeExtension: (EnumTypeExtensionNode.t) => t = "%identity"
  external fromInputObjectTypeExtension: (InputObjectTypeExtensionNode.t) => t = "%identity"
}
module TypeSystemExtensionNode = {
  @tag("kind")
  type t =
    | ...SchemaExtensionNode.t
    | ...TypeExtensionNode.t
  @module("graphql")
  external print: t => string = "print"
  external fromSchemaExtension: (SchemaExtensionNode.t) => t = "%identity"
  external fromTypeExtension: (TypeExtensionNode.t) => t = "%identity"
}
module DefinitionNode = {
  @tag("kind")
  type t =
    | ...ExecutableDefinitionNode.t
    | ...TypeSystemDefinitionNode.t
    | ...TypeSystemExtensionNode.t
  @module("graphql")
  external print: t => string = "print"

  external fromExecutableDefinition: (ExecutableDefinitionNode.t) => t = "%identity"
  external fromTypeSystemDefinition: (TypeSystemDefinitionNode.t) => t = "%identity"
  external fromTypeSystemExtension: (TypeSystemExtensionNode.t) => t = "%identity"
}

module DocumentNode = {
  type t = {
    loc?: location,
    definitions: array<DefinitionNode.t>,
  }
  @module("graphql")
  external print: t => string = "print"
}
