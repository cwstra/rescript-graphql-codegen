import {
    isScalarType,
    isObjectType,
    isInterfaceType,
    isUnionType,
    isEnumType,
    isInputObjectType,
    isListType,
    isNonNullType,
    Kind,
    visit
} from "graphql"

export const wrapClassType = classType => {
    switch (true) {
        case isScalarType(classType):
            return { TAG: "Scalar", _0: classType }
        case isObjectType(classType):
            return { TAG: "Object", _0: classType }
        case isInterfaceType(classType):
            return { TAG: "Interface", _0: classType }
        case isUnionType(classType):
            return { TAG: "Union", _0: classType }
        case isEnumType(classType):
            return { TAG: "Enum", _0: classType }
        case isInputObjectType(classType):
            return { TAG: "InputObject", _0: classType }
        case isListType(classType):
            return { TAG: "List", _0: classType }
        case isNonNullType(classType):
            return { TAG: "NonNull", _0: classType }
    }
}

export const match = (value, acc, record) => {
    let result = acc;
    visit(value, {
      enter(node) {
        result = record[node.kind]?.(node, result)
      }
    })
    return result
}

// Ripped from https://github.com/apollographql/apollo-client/blob/eb2cfee1846b6271e438d1a268e187151e691db4/src/utilities/graphql/transform.ts#L453
const TYPENAME_FIELD = {
  kind: Kind.FIELD,
  name: {
    kind: Kind.NAME,
    value: "__typename"
  }
}
export const addTypenameToDocument = (document) =>
  visit(document, {
      SelectionSet: {
        enter(node, _key, parent) {
          // Don't add __typename to OperationDefinitions.
          if (
            parent &&
            parent.kind === Kind.OPERATION_DEFINITION
          ) {
            return;
          }

          // No changes if no selections.
          const { selections } = node;
          if (!selections) {
            return;
          }

          // If selections already have a __typename, or are part of an
          // introspection query, do nothing.
          const skip = selections.some((selection) => {
            return (
              selection.kind === Kind.Field &&
              (selection.name.value === "__typename" ||
                selection.name.value.lastIndexOf("__", 0) === 0)
            );
          });
          if (skip) {
            return;
          }

          /*
          // If this SelectionSet is @export-ed as an input variable, it should
          // not have a __typename field (see issue #4691).
          if (
            parent.kind === Kind.Field &&
            parent.directives &&
            parent.directives.some((d) => d.name.value === "export")
          ) {
            return;
          }
          */

          // Create and return a new SelectionSet with a __typename Field.
          return {
            ...node,
            selections: [...selections, TYPENAME_FIELD],
          };
        },
      },
    })
