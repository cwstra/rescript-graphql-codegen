import { isScalarType, isObjectType, isInterfaceType, isUnionType, isEnumType, isInputObjectType, isListType, isNonNullType } from "graphql"

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