open CorePlus

module Language = {
  type sourceLocation = {
    line: int,
    column: int,
  }

  type source = {
    body: string,
    name: string,
    locationOffset: sourceLocation,
  }
}

module AST = {
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
    external fromFragmentDefinition: FragmentDefinitionNode.t => t = "%identity"
    external fromOperationDefinition: OperationDefinitionNode.t => t = "%identity"
    let name = def =>
      switch def {
      | OperationDefinition({?name}) => name
      | FragmentDefinition({name}) => Some(name)
      }
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
    external fromScalarTypeDefinition: ScalarTypeDefinitionNode.t => t = "%identity"
    external fromInterfaceTypeDefinition: InterfaceTypeDefinitionNode.t => t = "%identity"
    external fromUnionTypeDefinition: UnionTypeDefinitionNode.t => t = "%identity"
    external fromEnumTypeDefinition: EnumTypeDefinitionNode.t => t = "%identity"
    external fromInputObjectTypeDefinition: InputObjectTypeDefinitionNode.t => t = "%identity"
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
    external fromSchemaDefinition: SchemaDefinitionNode.t => t = "%identity"
    external fromTypeDefinition: TypeDefinitionNode.t => t = "%identity"
    external fromDirectiveDefinitionNode: DirectiveDefinitionNode.t => t = "%identity"
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
    external fromScalarTypeExtension: ScalarTypeExtensionNode.t => t = "%identity"
    external fromObjectTypeExtension: ObjectTypeExtensionNode.t => t = "%identity"
    external fromInterfaceTypeExtension: InterfaceTypeExtensionNode.t => t = "%identity"
    external fromUnionTypeExtension: UnionTypeExtensionNode.t => t = "%identity"
    external fromEnumTypeExtension: EnumTypeExtensionNode.t => t = "%identity"
    external fromInputObjectTypeExtension: InputObjectTypeExtensionNode.t => t = "%identity"
  }
  module TypeSystemExtensionNode = {
    @tag("kind")
    type t =
      | ...SchemaExtensionNode.t
      | ...TypeExtensionNode.t
    @module("graphql")
    external print: t => string = "print"
    external fromSchemaExtension: SchemaExtensionNode.t => t = "%identity"
    external fromTypeExtension: TypeExtensionNode.t => t = "%identity"
  }
  module DefinitionNode = {
    @tag("kind")
    type t =
      | ...ExecutableDefinitionNode.t
      | ...TypeSystemDefinitionNode.t
      | ...TypeSystemExtensionNode.t
    @module("graphql")
    external print: t => string = "print"

    external fromExecutableDefinition: ExecutableDefinitionNode.t => t = "%identity"
    external fromTypeSystemDefinition: TypeSystemDefinitionNode.t => t = "%identity"
    external fromTypeSystemExtension: TypeSystemExtensionNode.t => t = "%identity"
  }

  module DocumentNode = {
    @tag("kind")
    type t = Document({loc?: location, definitions: array<DefinitionNode.t>})
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
  external addTypenameToDocument: DocumentNode.t => DocumentNode.t = "addTypenameToDocument"

  @module("./shims/graphql.mjs")
  external addTypenameToFragment: FragmentDefinitionNode.t => FragmentDefinitionNode.t =
    "addTypenameToDocument"
}

module Error = {
  @unboxed
  type jsonPath =
    | String(string)
    | Number(int)

  type t = {
    name: string,
    message: string,
    stack?: string,
    locations: option<array<Language.sourceLocation>>,
    path: option<array<jsonPath>>,
    nodes: option<array<AST.ASTNode.t>>,
    source: option<Language.source>,
    positions: option<array<int>>,
    originalError: Js.Exn.t,
  }
}

module Schema: {
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
    let name: t => string
  }

  module ValidForField: {
    type t =
      | ...UnionMembers.object
      | ...UnionMembers.interface
    let fromNamed: Named.parsed => option<t>
    let fromValidForTypeCondition: ValidForTypeCondition.t => option<t>
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
    let traverse: (
      t,
      ~onScalar: scalarType => 'r,
      ~onObject: objectType => 'r,
      ~onInterface: interfaceType => 'r,
      ~onUnion: unionType => 'r,
      ~onEnum: enumType => 'r,
      ~onList: 'r => 'r=?,
      ~onNull: 'r => 'r=?,
      ~onNonNull: 'r => 'r=?,
    ) => 'r
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
    let value: t => string
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

  module List: {
    let ofType: listType<'t> => 't
  }
  module NonNull: {
    let ofType: nonNullType<'t> => 't
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
} = {
  type schemaType<'def, 'ext> = {
    name: string,
    description: null<string>,
    astNode: null<'def>,
    extensionASTNodes: null<array<'ext>>,
  }

  type scalarType = schemaType<AST.ScalarTypeDefinitionNode.t, AST.ScalarTypeExtensionNode.t>
  type objectType = schemaType<AST.ObjectTypeDefinitionNode.t, AST.ObjectTypeExtensionNode.t>
  type interfaceType = schemaType<
    AST.InterfaceTypeDefinitionNode.t,
    AST.InterfaceTypeExtensionNode.t,
  >
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
    @module("./shims/graphql.mjs")
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
    @module("./shims/graphql.mjs")
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
    @module("./shims/graphql.mjs")
    external parse: t => parsed = "wrapClassType"
    @module("./shims/graphql.mjs")
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
    @module("./shims/graphql.mjs")
    external parse: t => parsed = "wrapClassType"
    @module("./shims/graphql.mjs")
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
  @send @return(nullable)
  external getSubscriptionType: t => option<Object.t> = "getSubscriptionType"
  @send external getTypeMap: t => Dict.t<Named.t> = "getTypeMap"
  @send @return(nullable) external getType: (t, string) => option<Named.t> = "getType"
  @send external getPossibleTypes: (t, Abstract.t) => array<Object.t> = "getPossibleTypes"
  @send external isPossibleType: (t, Abstract.t, Object.t) => bool = "isPossibleType"
  @send external getDirectives: t => array<Directive.t> = "getDirectives"
  @send @return(nullable)
  external getDirective: (t, string) => option<Directive.t> = "getDirectives"
}
