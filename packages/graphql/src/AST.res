type location = {
  start: int,
  end: int,
}

module NameNode = {
  @tag("kind")
  type t = Name({loc?: location, value: string})
  let loc = (Name({?loc})) => loc
  let value = (Name({value})) => value
  @module("graphql")
  external print: t => string = "print"
}

module VariableNode = {
  @tag("kind")
  type t = Variable({loc?: location, name: NameNode.t})
  let loc = (Variable({?loc})) => loc
  let name = (Variable({name})) => name
  @module("graphql")
  external print: t => string = "print"
}
module IntValueNode = {
  @tag("kind")
  type t = IntValue({loc?: location, value: string})
  let loc = (IntValue({?loc})) => loc
  let value = (IntValue({value})) => value
  @module("graphql")
  external print: t => string = "print"
}
module FloatValueNode = {
  @tag("kind")
  type t = FloatValue({loc?: location, value: string})
  let loc = (FloatValue({?loc})) => loc
  let value = (FloatValue({value})) => value
  @module("graphql")
  external print: t => string = "print"
}
module StringValueNode = {
  @tag("kind")
  type t = StringValue({loc?: location, value: string, block?: bool})
  let loc = (StringValue({?loc})) => loc
  let value = (StringValue({value})) => value
  let block = (StringValue({?block})) => block
  @module("graphql")
  external print: t => string = "print"
}
module BooleanValueNode = {
  @tag("kind")
  type t = BooleanValue({loc?: location, value: bool})
  let loc = (BooleanValue({?loc})) => loc
  let value = (BooleanValue({value})) => value
  @module("graphql")
  external print: t => string = "print"
}
module NullValueNode = {
  @tag("kind")
  type t = NullValue({loc?: location})
  let loc = (NullValue({?loc})) => loc
  @module("graphql")
  external print: t => string = "print"
}
module EnumValueNode = {
  @tag("kind")
  type t = EnumValue({loc?: location, value: string})
  let loc = (EnumValue({?loc})) => loc
  let value = (EnumValue({value})) => value
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
  let loc = (NamedType({?loc})) => loc
  let name = (NamedType({name})) => name
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
  let loc = (Argument({?loc})) => loc
  let name = (Argument({name})) => name
  let value = (Argument({value})) => value
  @module("graphql")
  external print: t => string = "print"
}
module DirectiveNode = {
  @tag("kind")
  type t = Directive({loc?: location, name: NameNode.t, arguments?: array<ArgumentNode.t>})
  let loc = (Directive({?loc})) => loc
  let name = (Directive({name})) => name
  let arguments = (Directive({?arguments})) => arguments
  @module("graphql")
  external print: t => string = "print"
}
module VariableDefinitionNode = {
  @tag("kind")
  type t =
    | VariableDefinition({
        loc?: location,
        variable: VariableNode.t,
        @as("type") type_: TypeNode.t,
        defaultValue?: ValueNode.t,
        directives?: DirectiveNode.t,
      })

  let loc = (VariableDefinition({?loc})) => loc
  let variable = (VariableDefinition({variable})) => variable
  let type_ = (VariableDefinition({type_})) => type_
  let defaultValue = (VariableDefinition({?defaultValue})) => defaultValue
  let directives = (VariableDefinition({?directives})) => directives
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
  let loc = (SelectionSet({?loc})) => loc
  let selections = (SelectionSet({selections})) => selections
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
  let loc = (OperationTypeDefinition({?loc})) => loc
  let operation = (OperationTypeDefinition({operation})) => operation
  let type_ = (OperationTypeDefinition({type_})) => type_
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
  let loc = (InputValueDefinition({?loc})) => loc
  let description = (InputValueDefinition({?description})) => description
  let name = (InputValueDefinition({name})) => name
  let type_ = (InputValueDefinition({type_})) => type_
  let defaultValue = (InputValueDefinition({?defaultValue})) => defaultValue
  let directives = (InputValueDefinition({?directives})) => directives
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
  let loc = (FieldDefinition({?loc})) => loc
  let description = (FieldDefinition({?description})) => description
  let name = (FieldDefinition({name})) => name
  let arguments = (FieldDefinition({?arguments})) => arguments
  let type_ = (FieldDefinition({type_})) => type_
  let directives = (FieldDefinition({?directives})) => directives
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
  let loc = (EnumValueDefinition({?loc})) => loc
  let description = (EnumValueDefinition({?description})) => description
  let name = (EnumValueDefinition({name})) => name
  let directives = (EnumValueDefinition({?directives})) => directives
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
  let loc = (OperationDefinition({?loc})) => loc
  let operation = (OperationDefinition({operation})) => operation
  let name = (OperationDefinition({?name})) => name
  let variableDefinitions = (OperationDefinition({?variableDefinitions})) => variableDefinitions
  let directives = (OperationDefinition({?directives})) => directives
  let selectionSet = (OperationDefinition({selectionSet})) => selectionSet
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
  let loc = (FragmentDefinition({?loc})) => loc
  let name = (FragmentDefinition({name})) => name
  let variableDefinitions = (FragmentDefinition({?variableDefinitions})) => variableDefinitions
  let typeCondition = (FragmentDefinition({typeCondition})) => typeCondition
  let directives = (FragmentDefinition({?directives})) => directives
  let selectionSet = (FragmentDefinition({selectionSet})) => selectionSet
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
  let loc = (SchemaDefinition({?loc})) => loc
  let directives = (SchemaDefinition({?directives})) => directives
  let operationTypes = (SchemaDefinition({operationTypes})) => operationTypes
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
  let loc = (ScalarTypeDefinition({?loc})) => loc
  let description = (ScalarTypeDefinition({?description})) => description
  let name = (ScalarTypeDefinition({name})) => name
  let directives = (ScalarTypeDefinition({?directives})) => directives
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
  let loc = (ObjectTypeDefinition({?loc})) => loc
  let description = (ObjectTypeDefinition({?description})) => description
  let name = (ObjectTypeDefinition({name})) => name
  let interfaces = (ObjectTypeDefinition({?interfaces})) => interfaces
  let directives = (ObjectTypeDefinition({?directives})) => directives
  let fields = (ObjectTypeDefinition({?fields})) => fields
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
  let loc = (InterfaceTypeDefinition({?loc})) => loc
  let description = (InterfaceTypeDefinition({?description})) => description
  let name = (InterfaceTypeDefinition({name})) => name
  let directives = (InterfaceTypeDefinition({?directives})) => directives
  let fields = (InterfaceTypeDefinition({?fields})) => fields
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
  let loc = (UnionTypeDefinition({?loc})) => loc
  let description = (UnionTypeDefinition({?description})) => description
  let name = (UnionTypeDefinition({name})) => name
  let directives = (UnionTypeDefinition({directives})) => directives
  let types = (UnionTypeDefinition({?types})) => types
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
  let loc = (EnumTypeDefinition({?loc})) => loc
  let description = (EnumTypeDefinition({?description})) => description
  let name = (EnumTypeDefinition({name})) => name
  let directives = (EnumTypeDefinition({?directives})) => directives
  let values = (EnumTypeDefinition({?values})) => values
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
  let loc = (InputObjectTypeDefinition({?loc})) => loc
  let description = (InputObjectTypeDefinition({?description})) => description
  let name = (InputObjectTypeDefinition({name})) => name
  let directives = (InputObjectTypeDefinition({?directives})) => directives
  let fields = (InputObjectTypeDefinition({?fields})) => fields
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
  let loc = (DirectiveDefinition({?loc})) => loc
  let description = (DirectiveDefinition({?description})) => description
  let name = (DirectiveDefinition({name})) => name
  let arguments = (DirectiveDefinition({arguments})) => arguments
  let repeatable = (DirectiveDefinition({repeatable})) => repeatable
  let locations = (DirectiveDefinition({locations})) => locations
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
  let loc = (SchemaExtension({?loc})) => loc
  let directives = (SchemaExtension({?directives})) => directives
  let operationTypes = (SchemaExtension({?operationTypes})) => operationTypes
  @module("graphql")
  external print: t => string = "print"
}
module ScalarTypeExtensionNode = {
  @tag("kind")
  type t =
    ScalarTypeExtension({loc?: location, name: NameNode.t, directives?: array<DirectiveNode.t>})
  let loc = (ScalarTypeExtension({?loc})) => loc
  let name = (ScalarTypeExtension({name})) => name
  let directives = (ScalarTypeExtension({?directives})) => directives
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
  let loc = (ObjectTypeExtension({?loc})) => loc
  let name = (ObjectTypeExtension({name})) => name
  let interfaces = (ObjectTypeExtension({?interfaces})) => interfaces
  let directives = (ObjectTypeExtension({?directives})) => directives
  let fields = (ObjectTypeExtension({?fields})) => fields
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
  let loc = (InterfaceTypeExtension({?loc})) => loc
  let name = (InterfaceTypeExtension({name})) => name
  let directives = (InterfaceTypeExtension({?directives})) => directives
  let fields = (InterfaceTypeExtension({?fields})) => fields
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
  let loc = (UnionTypeExtension({?loc})) => loc
  let name = (UnionTypeExtension({name})) => name
  let directives = (UnionTypeExtension({?directives})) => directives
  let types = (UnionTypeExtension({?types})) => types
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
  let loc = (EnumTypeExtension({?loc})) => loc
  let name = (EnumTypeExtension({name})) => name
  let directives = (EnumTypeExtension({?directives})) => directives
  let values = (EnumTypeExtension({?values})) => values
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
  let loc = (InputObjectTypeExtension({?loc})) => loc
  let name = (InputObjectTypeExtension({name})) => name
  let directives = (InputObjectTypeExtension({?directives})) => directives
  let fields = (InputObjectTypeExtension({?fields})) => fields
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
  @tag("kind")
  type t =
    Document({
      loc?: location,
      definitions: array<DefinitionNode.t>,
    })
  @module("graphql")
  external print: t => string = "print"
}

module ASTNode = {
  @tag("kind")
  type t =
    | ...NameNode.t
    | ...DocumentNode.t
    | ...OperationDefinitionNode.t
    | ...VariableDefinitionNode.t
    | ...SelectionSetNode.t
    | ...SelectionSetNode.selectionNode
    | ...ArgumentNode.t
    | ...FragmentDefinitionNode.t
    | ...ValueNode.t
    //| ...VariableNode.t
    //| ...IntValueNode.t
    //| ...FloatValueNode.t
    //| ...StringValueNode.t
    //| ...BooleanValueNode.t
    //| ...NullValueNode.t
    //| ...EnumValueNode.t
    | ...ValueNode.objectFieldNode
    | ...DirectiveNode.t
    | ...TypeNode.t
    //| ...NamedTypeNode.t
    //| ...ListTypeNode.t
    //| ...NonNullTypeNode.t
    | ...SchemaDefinitionNode.t
    | ...OperationTypeDefinitionNode.t
    | ...ScalarTypeDefinitionNode.t
    | ...ObjectTypeDefinitionNode.t
    | ...FieldDefinitionNode.t
    | ...InputValueDefinitionNode.t
    | ...InterfaceTypeDefinitionNode.t
    | ...UnionTypeDefinitionNode.t
    | ...EnumTypeDefinitionNode.t
    | ...EnumValueDefinitionNode.t
    | ...InputObjectTypeDefinitionNode.t
    | ...DirectiveDefinitionNode.t
    | ...SchemaExtensionNode.t
    | ...ScalarTypeExtensionNode.t
    | ...ObjectTypeExtensionNode.t
    | ...InterfaceTypeExtensionNode.t
    | ...UnionTypeExtensionNode.t
    | ...EnumTypeExtensionNode.t
    | ...InputObjectTypeExtensionNode.t
}

@module("./shims/graphql.mjs")
external addTypenameToDocument: (DocumentNode.t) => DocumentNode.t = "addTypenameToDocument"

@module("./shims/graphql.mjs")
external addTypenameToFragment: (FragmentDefinitionNode.t) => FragmentDefinitionNode.t = "addTypenameToDocument"
