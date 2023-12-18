type location = {
  start: int,
  end: int,
}

@tag("kind")
type nameNode =
  | NameNode({loc?: location, value: string})

@tag("kind")
type variableNode =
  | Variable({loc?: location, name: nameNode})
@tag("kind")
type intValueNode =
  | IntValue({loc?: location, value: string})
@tag("kind")
type floatValueNode =
  | FloatValue({loc?: location, value: string})
@tag("kind")
type stringValueNode =
  | StringValue({loc?: location, value: string, block?: bool})
@tag("kind")
type booleanValueNode =
  | BooleanValue({loc?: location, value: bool})
@tag("kind")
type nullValueNode =
  | NullValue({loc?: location})
@tag("kind")
type enumValueNode =
  | EnumValue({loc?: location, value: string})
@tag("kind")
type rec valueNode =
  | ...variableNode
  | ...intValueNode
  | ...floatValueNode
  | ...stringValueNode
  | ...booleanValueNode
  | ...nullValueNode
  | ...enumValueNode
  | ListValue({loc?: location, values: array<valueNode>})
  | ObjectValue({loc?: location, fields: array<objectFieldNode>})
@tag("kind")
and objectFieldNode =
  | ObjectField({loc?: location, name: nameNode, value: valueNode})

@tag("kind")
type namedTypeNode =
  | NamedType({loc?: location, name: nameNode})
@@warning("-30")
@tag("kind")
type rec typeNode =
  | ...namedTypeNode
  | ListType({
      loc?: location,
      @as("type")
      type_: typeNode,
    })
  | NonNullType({
      loc?: location,
      @as("type")
      type_: listOrNamedTypeNode,
    })
@tag("kind")
and listOrNamedTypeNode =
  | ...namedTypeNode
  | ListType({
      loc?: location,
      @as("type")
      type_: typeNode,
    })
@@warning("+30")

@unboxed
type operationTypeNode =
  | @as("query") Query
  | @as("mutation") Mutation
  | @as("subscription") Subscription

@tag("kind")
type argumentNode =
  | Argument({loc?: location, name: nameNode, value: valueNode})
@tag("kind")
type directiveNode =
  | Directive({loc?: location, name: nameNode, arguments?: array<argumentNode>})
@tag("kind")
type variableDefinitionNode =
  | VariableDefinition({
      loc?: location,
      variable: variableNode,
      @as("type")
      type_: typeNode,
      defaultValue?: valueNode,
      directives?: directiveNode,
    })

@tag("kind")
type rec selectionNode =
  | Field({
      loc?: location,
      alias?: nameNode,
      name: nameNode,
      arguments?: array<argumentNode>,
      directives?: array<directiveNode>,
      selectionSet?: selectionSetNode,
    })
  | FragmentSpread({loc?: location, name: nameNode, directives?: array<directiveNode>})
  | InlineFragment({
      loc?: location,
      typeCondition?: namedTypeNode,
      directives?: array<directiveNode>,
      selectionSet: selectionSetNode,
    })
@tag("kind")
and selectionSetNode =
  | SelectionSet({loc?: location, selections: array<selectionNode>})
@tag("kind")
type operationTypeDefinitionNode =
  | OperationTypeDefinition({
      loc?: location,
      operation: operationTypeNode,
      @as("type")
      type_: namedTypeNode,
    })
@tag("kind")
type inputValueDefinitionNode =
  | InputValueDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      @as("type")
      type_: typeNode,
      defaultValue?: valueNode,
      directives?: array<directiveNode>,
    })
@tag("kind")
type fieldDefinitionNode =
  | FieldDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      arguments?: array<inputValueDefinitionNode>,
      @as("type")
      type_: typeNode,
      directives?: array<directiveNode>,
    })
@tag("kind")
type enumValueDefinitionNode =
  | EnumValueDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      directives?: array<directiveNode>,
    })
@tag("kind")
type operationDefinitionNode =
  | OperationDefinition({
      loc?: location,
      operation: operationTypeNode,
      name?: nameNode,
      variableDefinitions?: array<variableDefinitionNode>,
      directives?: array<directiveNode>,
      selectionSet: selectionSetNode,
    })
@tag("kind")
type fragmentDefinitionNode =
  | FragmentDefinition({
      loc?: location,
      operation: operationTypeNode,
      name?: nameNode,
      variableDefinitions?: array<variableDefinitionNode>,
      directives?: array<directiveNode>,
      selectionSet: selectionSetNode,
    })
@tag("kind")
type executableDefinitionNode =
  | ...operationDefinitionNode
  | ...fragmentDefinitionNode
@tag("kind")
type schemaDefinitionNode =
  | SchemaDefinition({
      loc?: location,
      directives?: array<directiveNode>,
      operationTypes: array<operationTypeDefinitionNode>,
    })
@tag("kind")
type scalarTypeDefinitionNode =
  | ScalarTypeDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      directives?: array<directiveNode>,
    })
@tag("kind")
type objectTypeDefinitionNode =
  | ObjectTypeDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      interfaces?: array<namedTypeNode>,
      directives?: array<directiveNode>,
      fields?: array<fieldDefinitionNode>,
    })
@tag("kind")
type interfaceTypeDefinitionNode =
  | InterfaceTypeDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      directives?: array<directiveNode>,
      field?: array<fieldDefinitionNode>,
    })
@tag("kind")
type unionTypeDefinitionNode =
  | UnionTypeDefinitionNode({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      directives: array<directiveNode>,
      types?: array<namedTypeNode>,
    })
@tag("kind")
type enumTypeDefinitionNode =
  | EnumTypeDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      directives?: array<directiveNode>,
      values?: array<enumValueDefinitionNode>,
    })
@tag("kind")
type inputObjectTypeDefinitionNode =
  | InputObjectTypeDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      directives?: array<directiveNode>,
      fields?: array<inputValueDefinitionNode>,
    })
@tag("kind")
type typeDefinitionNode =
  | ...scalarTypeDefinitionNode
  | ...interfaceTypeDefinitionNode
  | ...unionTypeDefinitionNode
  | ...enumTypeDefinitionNode
  | ...inputObjectTypeDefinitionNode
@tag("kind")
type directiveDefinitionNode =
  | DirectiveDefinition({
      loc?: location,
      description?: stringValueNode,
      name: nameNode,
      arguments: array<inputValueDefinitionNode>,
      repeatable: bool,
      locations: array<nameNode>,
    })
@tag("kind")
type typeSystemDefinitionNode =
  | ...schemaDefinitionNode
  | ...typeDefinitionNode
  | ...directiveDefinitionNode
@tag("kind")
type schemaExtensionNode =
  | SchemaExtension({
      loc?: location,
      directives?: array<directiveNode>,
      operationTypes?: array<operationTypeDefinitionNode>,
    })
@tag("kind")
type scalarTypeExtensionNode =
  | ScalarTypeExtension({loc?: location, name: nameNode, directives?: array<directiveNode>})
@tag("kind")
type objectTypeExtensionNode =
  | ObjectTypeExtension({
      loc?: location,
      name: nameNode,
      interfaces?: array<namedTypeNode>,
      directives?: array<directiveNode>,
      fields?: array<fieldDefinitionNode>,
    })
@tag("kind")
type interfaceTypeExtensionNode =
  | InterfaceTypeExtension({
      loc?: location,
      name: nameNode,
      directives?: array<directiveNode>,
      fields?: array<fieldDefinitionNode>,
    })
@tag("kind")
type unionTypeExtensionNode =
  | UnionTypeExtension({
      loc?: location,
      name: nameNode,
      directives?: array<directiveNode>,
      types?: array<namedTypeNode>,
    })
@tag("kind")
type enumTypeExtensionNode =
  | EnumTypeExtension({
      loc?: location,
      name: nameNode,
      directives?: array<directiveNode>,
      values?: array<enumValueDefinitionNode>,
    })
@tag("kind")
type inputObjectTypeExtensionNode =
  | InputObjectTypeExtension({
      loc?: location,
      name: nameNode,
      directives?: array<directiveNode>,
      fields?: array<inputValueDefinitionNode>,
    })
@tag("kind")
type typeExtensionNode =
  | ...scalarTypeExtensionNode
  | ...objectTypeExtensionNode
  | ...interfaceTypeExtensionNode
  | ...unionTypeExtensionNode
  | ...enumTypeExtensionNode
  | ...inputObjectTypeExtensionNode
@tag("kind")
type typeSystemExtensionNode =
  | ...schemaExtensionNode
  | ...typeExtensionNode
@tag("kind")
type definitionNode =
  | ...executableDefinitionNode
  | ...typeSystemDefinitionNode
  | ...typeSystemExtensionNode

type documentNode = {
  loc?: location,
  definitions: array<definitionNode>,
}
