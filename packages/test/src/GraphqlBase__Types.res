module DirectiveLocation = {
  type t = 
    | @as("QUERY")
    Query
    | @as("MUTATION")
    Mutation
    | @as("SUBSCRIPTION")
    Subscription
    | @as("FIELD")
    Field
    | @as("FRAGMENT_DEFINITION")
    FragmentDefinition
    | @as("FRAGMENT_SPREAD")
    FragmentSpread
    | @as("INLINE_FRAGMENT")
    InlineFragment
    | @as("VARIABLE_DEFINITION")
    VariableDefinition
    | @as("SCHEMA")
    Schema
    | @as("SCALAR")
    Scalar
    | @as("OBJECT")
    Object
    | @as("FIELD_DEFINITION")
    FieldDefinition
    | @as("ARGUMENT_DEFINITION")
    ArgumentDefinition
    | @as("INTERFACE")
    Interface
    | @as("UNION")
    Union
    | @as("ENUM")
    Enum
    | @as("ENUM_VALUE")
    EnumValue
    | @as("INPUT_OBJECT")
    InputObject
    | @as("INPUT_FIELD_DEFINITION")
    InputFieldDefinition
}

module TypeKind = {
  type t = 
    | @as("SCALAR")
    Scalar
    | @as("OBJECT")
    Object
    | @as("INTERFACE")
    Interface
    | @as("UNION")
    Union
    | @as("ENUM")
    Enum
    | @as("INPUT_OBJECT")
    InputObject
    | @as("LIST")
    List
    | @as("NON_NULL")
    NonNull
}

module ConflictAction = {
  type t = 
    | @as("ignore")
    Ignore
    | @as("update")
    Update
}

module OrderBy = {
  type t = 
    | @as("asc")
    Asc
    | @as("asc_nulls_first")
    AscNullsFirst
    | @as("asc_nulls_last")
    AscNullsLast
    | @as("desc")
    Desc
    | @as("desc_nulls_first")
    DescNullsFirst
    | @as("desc_nulls_last")
    DescNullsLast
}

module UsersConstraint = {
  type t = 
    | @as("constraint")
    Constraint
    | @as("key")
    Key
    | @as("or")
    Or
    | @as("primary")
    Primary
    | @as("unique")
    Unique
    | @as("users_pkey")
    UsersPkey
}

module UsersSelectColumn = {
  type t = 
    | @as("column")
    Column
    | @as("id")
    Id
    | @as("name")
    Name
    | @as("rocket")
    Rocket
    | @as("timestamp")
    Timestamp
    | @as("twitter")
    Twitter
}

module UsersUpdateColumn = {
  type t = 
    | @as("column")
    Column
    | @as("id")
    Id
    | @as("name")
    Name
    | @as("rocket")
    Rocket
    | @as("timestamp")
    Timestamp
    | @as("twitter")
    Twitter
}

module CapsulesFind = {
  type t = {
    id: null<GraphqlBase__Scalars.Id.t>,
    landings: null<GraphqlBase__Scalars.Int.t>,
    mission: null<GraphqlBase__Scalars.String.t>,
    original_launch: null<GraphqlBase__Scalars.Date.t>,
    reuse_count: null<GraphqlBase__Scalars.Int.t>,
    status: null<GraphqlBase__Scalars.String.t>,
    @as("type")
    type_: null<GraphqlBase__Scalars.String.t>,
  }
}

module CoresFind = {
  type t = {
    asds_attempts: null<GraphqlBase__Scalars.Int.t>,
    asds_landings: null<GraphqlBase__Scalars.Int.t>,
    block: null<GraphqlBase__Scalars.Int.t>,
    id: null<GraphqlBase__Scalars.String.t>,
    missions: null<GraphqlBase__Scalars.String.t>,
    original_launch: null<GraphqlBase__Scalars.Date.t>,
    reuse_count: null<GraphqlBase__Scalars.Int.t>,
    rtls_attempts: null<GraphqlBase__Scalars.Int.t>,
    rtls_landings: null<GraphqlBase__Scalars.Int.t>,
    status: null<GraphqlBase__Scalars.String.t>,
    water_landing: null<GraphqlBase__Scalars.Boolean.t>,
  }
}

module HistoryFind = {
  type t = {
    end: null<GraphqlBase__Scalars.Date.t>,
    flight_number: null<GraphqlBase__Scalars.Int.t>,
    id: null<GraphqlBase__Scalars.Id.t>,
    start: null<GraphqlBase__Scalars.Date.t>,
  }
}

module LaunchFind = {
  type t = {
    apoapsis_km: null<GraphqlBase__Scalars.Float.t>,
    block: null<GraphqlBase__Scalars.Int.t>,
    cap_serial: null<GraphqlBase__Scalars.String.t>,
    capsule_reuse: null<GraphqlBase__Scalars.String.t>,
    core_flight: null<GraphqlBase__Scalars.Int.t>,
    core_reuse: null<GraphqlBase__Scalars.String.t>,
    core_serial: null<GraphqlBase__Scalars.String.t>,
    customer: null<GraphqlBase__Scalars.String.t>,
    eccentricity: null<GraphqlBase__Scalars.Float.t>,
    end: null<GraphqlBase__Scalars.Date.t>,
    epoch: null<GraphqlBase__Scalars.Date.t>,
    fairings_recovered: null<GraphqlBase__Scalars.String.t>,
    fairings_recovery_attempt: null<GraphqlBase__Scalars.String.t>,
    fairings_reuse: null<GraphqlBase__Scalars.String.t>,
    fairings_reused: null<GraphqlBase__Scalars.String.t>,
    fairings_ship: null<GraphqlBase__Scalars.String.t>,
    gridfins: null<GraphqlBase__Scalars.String.t>,
    id: null<GraphqlBase__Scalars.Id.t>,
    inclination_deg: null<GraphqlBase__Scalars.Float.t>,
    land_success: null<GraphqlBase__Scalars.String.t>,
    landing_intent: null<GraphqlBase__Scalars.String.t>,
    landing_type: null<GraphqlBase__Scalars.String.t>,
    landing_vehicle: null<GraphqlBase__Scalars.String.t>,
    launch_date_local: null<GraphqlBase__Scalars.Date.t>,
    launch_date_utc: null<GraphqlBase__Scalars.Date.t>,
    launch_success: null<GraphqlBase__Scalars.String.t>,
    launch_year: null<GraphqlBase__Scalars.String.t>,
    legs: null<GraphqlBase__Scalars.String.t>,
    lifespan_years: null<GraphqlBase__Scalars.Float.t>,
    longitude: null<GraphqlBase__Scalars.Float.t>,
    manufacturer: null<GraphqlBase__Scalars.String.t>,
    mean_motion: null<GraphqlBase__Scalars.Float.t>,
    mission_id: null<GraphqlBase__Scalars.String.t>,
    mission_name: null<GraphqlBase__Scalars.String.t>,
    nationality: null<GraphqlBase__Scalars.String.t>,
    norad_id: null<GraphqlBase__Scalars.Int.t>,
    orbit: null<GraphqlBase__Scalars.String.t>,
    payload_id: null<GraphqlBase__Scalars.String.t>,
    payload_type: null<GraphqlBase__Scalars.String.t>,
    periapsis_km: null<GraphqlBase__Scalars.Float.t>,
    period_min: null<GraphqlBase__Scalars.Float.t>,
    raan: null<GraphqlBase__Scalars.Float.t>,
    reference_system: null<GraphqlBase__Scalars.String.t>,
    regime: null<GraphqlBase__Scalars.String.t>,
    reused: null<GraphqlBase__Scalars.String.t>,
    rocket_id: null<GraphqlBase__Scalars.String.t>,
    rocket_name: null<GraphqlBase__Scalars.String.t>,
    rocket_type: null<GraphqlBase__Scalars.String.t>,
    second_stage_block: null<GraphqlBase__Scalars.String.t>,
    semi_major_axis_km: null<GraphqlBase__Scalars.Float.t>,
    ship: null<GraphqlBase__Scalars.String.t>,
    side_core1_reuse: null<GraphqlBase__Scalars.String.t>,
    side_core2_reuse: null<GraphqlBase__Scalars.String.t>,
    site_id: null<GraphqlBase__Scalars.String.t>,
    site_name: null<GraphqlBase__Scalars.String.t>,
    site_name_long: null<GraphqlBase__Scalars.String.t>,
    start: null<GraphqlBase__Scalars.Date.t>,
    tbd: null<GraphqlBase__Scalars.String.t>,
    tentative: null<GraphqlBase__Scalars.String.t>,
    tentative_max_precision: null<GraphqlBase__Scalars.String.t>,
  }
}

module MissionsFind = {
  type t = {
    id: null<GraphqlBase__Scalars.Id.t>,
    manufacturer: null<GraphqlBase__Scalars.String.t>,
    name: null<GraphqlBase__Scalars.String.t>,
    payload_id: null<GraphqlBase__Scalars.String.t>,
  }
}

module PayloadsFind = {
  type t = {
    apoapsis_km: null<GraphqlBase__Scalars.Float.t>,
    customer: null<GraphqlBase__Scalars.String.t>,
    eccentricity: null<GraphqlBase__Scalars.Float.t>,
    epoch: null<GraphqlBase__Scalars.Date.t>,
    inclination_deg: null<GraphqlBase__Scalars.Float.t>,
    lifespan_years: null<GraphqlBase__Scalars.Float.t>,
    longitude: null<GraphqlBase__Scalars.Float.t>,
    manufacturer: null<GraphqlBase__Scalars.String.t>,
    mean_motion: null<GraphqlBase__Scalars.Float.t>,
    nationality: null<GraphqlBase__Scalars.String.t>,
    norad_id: null<GraphqlBase__Scalars.Int.t>,
    orbit: null<GraphqlBase__Scalars.String.t>,
    payload_id: null<GraphqlBase__Scalars.Id.t>,
    payload_type: null<GraphqlBase__Scalars.String.t>,
    periapsis_km: null<GraphqlBase__Scalars.Float.t>,
    period_min: null<GraphqlBase__Scalars.Float.t>,
    raan: null<GraphqlBase__Scalars.Float.t>,
    reference_system: null<GraphqlBase__Scalars.String.t>,
    regime: null<GraphqlBase__Scalars.String.t>,
    reused: null<GraphqlBase__Scalars.Boolean.t>,
    semi_major_axis_km: null<GraphqlBase__Scalars.Float.t>,
  }
}

module ShipsFind = {
  type t = {
    abs: null<GraphqlBase__Scalars.Int.t>,
    active: null<GraphqlBase__Scalars.Boolean.t>,
    attempted_landings: null<GraphqlBase__Scalars.Int.t>,
    class: null<GraphqlBase__Scalars.Int.t>,
    course_deg: null<GraphqlBase__Scalars.Int.t>,
    home_port: null<GraphqlBase__Scalars.String.t>,
    id: null<GraphqlBase__Scalars.Id.t>,
    imo: null<GraphqlBase__Scalars.Int.t>,
    latitude: null<GraphqlBase__Scalars.Float.t>,
    longitude: null<GraphqlBase__Scalars.Float.t>,
    mission: null<GraphqlBase__Scalars.String.t>,
    mmsi: null<GraphqlBase__Scalars.Int.t>,
    model: null<GraphqlBase__Scalars.String.t>,
    name: null<GraphqlBase__Scalars.String.t>,
    role: null<GraphqlBase__Scalars.String.t>,
    speed_kn: null<GraphqlBase__Scalars.Int.t>,
    status: null<GraphqlBase__Scalars.String.t>,
    successful_landings: null<GraphqlBase__Scalars.Int.t>,
    @as("type")
    type_: null<GraphqlBase__Scalars.String.t>,
    weight_kg: null<GraphqlBase__Scalars.Int.t>,
    weight_lbs: null<GraphqlBase__Scalars.Int.t>,
    year_built: null<GraphqlBase__Scalars.Int.t>,
  }
}

module StringComparisonExp = {
  type t = {
    _eq: null<GraphqlBase__Scalars.String.t>,
    _gt: null<GraphqlBase__Scalars.String.t>,
    _gte: null<GraphqlBase__Scalars.String.t>,
    _ilike: null<GraphqlBase__Scalars.String.t>,
    _in: null<array<GraphqlBase__Scalars.String.t>>,
    _is_null: null<GraphqlBase__Scalars.Boolean.t>,
    _like: null<GraphqlBase__Scalars.String.t>,
    _lt: null<GraphqlBase__Scalars.String.t>,
    _lte: null<GraphqlBase__Scalars.String.t>,
    _neq: null<GraphqlBase__Scalars.String.t>,
    _nilike: null<GraphqlBase__Scalars.String.t>,
    _nin: null<array<GraphqlBase__Scalars.String.t>>,
    _nlike: null<GraphqlBase__Scalars.String.t>,
    _nsimilar: null<GraphqlBase__Scalars.String.t>,
    _similar: null<GraphqlBase__Scalars.String.t>,
  }
}

module TimestamptzComparisonExp = {
  type t = {
    _eq: null<GraphqlBase__Scalars.Timestamptz.t>,
    _gt: null<GraphqlBase__Scalars.Timestamptz.t>,
    _gte: null<GraphqlBase__Scalars.Timestamptz.t>,
    _in: null<array<GraphqlBase__Scalars.Timestamptz.t>>,
    _is_null: null<GraphqlBase__Scalars.Boolean.t>,
    _lt: null<GraphqlBase__Scalars.Timestamptz.t>,
    _lte: null<GraphqlBase__Scalars.Timestamptz.t>,
    _neq: null<GraphqlBase__Scalars.Timestamptz.t>,
    _nin: null<array<GraphqlBase__Scalars.Timestamptz.t>>,
  }
}

module UsersInsertInput = {
  type t = {
    id: null<GraphqlBase__Scalars.Uuid.t>,
    name: null<GraphqlBase__Scalars.String.t>,
    rocket: null<GraphqlBase__Scalars.String.t>,
    timestamp: null<GraphqlBase__Scalars.Timestamptz.t>,
    twitter: null<GraphqlBase__Scalars.String.t>,
  }
}

module UsersMaxOrderBy = {
  type t = {
    name: null<OrderBy.t>,
    rocket: null<OrderBy.t>,
    timestamp: null<OrderBy.t>,
    twitter: null<OrderBy.t>,
  }
}

module UsersMinOrderBy = {
  type t = {
    name: null<OrderBy.t>,
    rocket: null<OrderBy.t>,
    timestamp: null<OrderBy.t>,
    twitter: null<OrderBy.t>,
  }
}

module UsersOnConflict = {
  type t = {
    @as("constraint")
    constraint_: UsersConstraint.t,
    update_columns: array<UsersUpdateColumn.t>,
  }
}

module UsersOrderBy = {
  type t = {
    id: null<OrderBy.t>,
    name: null<OrderBy.t>,
    rocket: null<OrderBy.t>,
    timestamp: null<OrderBy.t>,
    twitter: null<OrderBy.t>,
  }
}

module UsersSetInput = {
  type t = {
    id: null<GraphqlBase__Scalars.Uuid.t>,
    name: null<GraphqlBase__Scalars.String.t>,
    rocket: null<GraphqlBase__Scalars.String.t>,
    timestamp: null<GraphqlBase__Scalars.Timestamptz.t>,
    twitter: null<GraphqlBase__Scalars.String.t>,
  }
}

module UuidComparisonExp = {
  type t = {
    _eq: null<GraphqlBase__Scalars.Uuid.t>,
    _gt: null<GraphqlBase__Scalars.Uuid.t>,
    _gte: null<GraphqlBase__Scalars.Uuid.t>,
    _in: null<array<GraphqlBase__Scalars.Uuid.t>>,
    _is_null: null<GraphqlBase__Scalars.Boolean.t>,
    _lt: null<GraphqlBase__Scalars.Uuid.t>,
    _lte: null<GraphqlBase__Scalars.Uuid.t>,
    _neq: null<GraphqlBase__Scalars.Uuid.t>,
    _nin: null<array<GraphqlBase__Scalars.Uuid.t>>,
  }
}

module UsersAggregateOrderBy = {
  type t = {
    count: null<OrderBy.t>,
    max: null<UsersMaxOrderBy.t>,
    min: null<UsersMinOrderBy.t>,
  }
}

module UsersArrRelInsertInput = {
  type t = {
    data: array<UsersInsertInput.t>,
    on_conflict: null<UsersOnConflict.t>,
  }
}

module UsersObjRelInsertInput = {
  type t = {
    data: UsersInsertInput.t,
    on_conflict: null<UsersOnConflict.t>,
  }
}

module rec UsersBoolExp: {
  type t = {
    _and: null<array<null<UsersBoolExp.t>>>,
    _not: null<UsersBoolExp.t>,
    _or: null<array<null<UsersBoolExp.t>>>,
    id: null<UuidComparisonExp.t>,
    name: null<StringComparisonExp.t>,
    rocket: null<StringComparisonExp.t>,
    timestamp: null<TimestamptzComparisonExp.t>,
    twitter: null<StringComparisonExp.t>,
  }
} = UsersBoolExp

module Tester = {
  type t = {
    _value: null<UsersBoolExp.t>,
  }
}