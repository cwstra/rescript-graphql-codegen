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
    id: null<GraphqlBase.Scalars.Id.t>,
    landings: null<GraphqlBase.Scalars.Int.t>,
    mission: null<GraphqlBase.Scalars.String.t>,
    original_launch: null<GraphqlBase.Scalars.Date.t>,
    reuse_count: null<GraphqlBase.Scalars.Int.t>,
    status: null<GraphqlBase.Scalars.String.t>,
    @as("type")
    type_: null<GraphqlBase.Scalars.String.t>,
  }
}

module CoresFind = {
  type t = {
    asds_attempts: null<GraphqlBase.Scalars.Int.t>,
    asds_landings: null<GraphqlBase.Scalars.Int.t>,
    block: null<GraphqlBase.Scalars.Int.t>,
    id: null<GraphqlBase.Scalars.String.t>,
    missions: null<GraphqlBase.Scalars.String.t>,
    original_launch: null<GraphqlBase.Scalars.Date.t>,
    reuse_count: null<GraphqlBase.Scalars.Int.t>,
    rtls_attempts: null<GraphqlBase.Scalars.Int.t>,
    rtls_landings: null<GraphqlBase.Scalars.Int.t>,
    status: null<GraphqlBase.Scalars.String.t>,
    water_landing: null<GraphqlBase.Scalars.Boolean.t>,
  }
}

module HistoryFind = {
  type t = {
    end: null<GraphqlBase.Scalars.Date.t>,
    flight_number: null<GraphqlBase.Scalars.Int.t>,
    id: null<GraphqlBase.Scalars.Id.t>,
    start: null<GraphqlBase.Scalars.Date.t>,
  }
}

module LaunchFind = {
  type t = {
    apoapsis_km: null<GraphqlBase.Scalars.Float.t>,
    block: null<GraphqlBase.Scalars.Int.t>,
    cap_serial: null<GraphqlBase.Scalars.String.t>,
    capsule_reuse: null<GraphqlBase.Scalars.String.t>,
    core_flight: null<GraphqlBase.Scalars.Int.t>,
    core_reuse: null<GraphqlBase.Scalars.String.t>,
    core_serial: null<GraphqlBase.Scalars.String.t>,
    customer: null<GraphqlBase.Scalars.String.t>,
    eccentricity: null<GraphqlBase.Scalars.Float.t>,
    end: null<GraphqlBase.Scalars.Date.t>,
    epoch: null<GraphqlBase.Scalars.Date.t>,
    fairings_recovered: null<GraphqlBase.Scalars.String.t>,
    fairings_recovery_attempt: null<GraphqlBase.Scalars.String.t>,
    fairings_reuse: null<GraphqlBase.Scalars.String.t>,
    fairings_reused: null<GraphqlBase.Scalars.String.t>,
    fairings_ship: null<GraphqlBase.Scalars.String.t>,
    gridfins: null<GraphqlBase.Scalars.String.t>,
    id: null<GraphqlBase.Scalars.Id.t>,
    inclination_deg: null<GraphqlBase.Scalars.Float.t>,
    land_success: null<GraphqlBase.Scalars.String.t>,
    landing_intent: null<GraphqlBase.Scalars.String.t>,
    landing_type: null<GraphqlBase.Scalars.String.t>,
    landing_vehicle: null<GraphqlBase.Scalars.String.t>,
    launch_date_local: null<GraphqlBase.Scalars.Date.t>,
    launch_date_utc: null<GraphqlBase.Scalars.Date.t>,
    launch_success: null<GraphqlBase.Scalars.String.t>,
    launch_year: null<GraphqlBase.Scalars.String.t>,
    legs: null<GraphqlBase.Scalars.String.t>,
    lifespan_years: null<GraphqlBase.Scalars.Float.t>,
    longitude: null<GraphqlBase.Scalars.Float.t>,
    manufacturer: null<GraphqlBase.Scalars.String.t>,
    mean_motion: null<GraphqlBase.Scalars.Float.t>,
    mission_id: null<GraphqlBase.Scalars.String.t>,
    mission_name: null<GraphqlBase.Scalars.String.t>,
    nationality: null<GraphqlBase.Scalars.String.t>,
    norad_id: null<GraphqlBase.Scalars.Int.t>,
    orbit: null<GraphqlBase.Scalars.String.t>,
    payload_id: null<GraphqlBase.Scalars.String.t>,
    payload_type: null<GraphqlBase.Scalars.String.t>,
    periapsis_km: null<GraphqlBase.Scalars.Float.t>,
    period_min: null<GraphqlBase.Scalars.Float.t>,
    raan: null<GraphqlBase.Scalars.Float.t>,
    reference_system: null<GraphqlBase.Scalars.String.t>,
    regime: null<GraphqlBase.Scalars.String.t>,
    reused: null<GraphqlBase.Scalars.String.t>,
    rocket_id: null<GraphqlBase.Scalars.String.t>,
    rocket_name: null<GraphqlBase.Scalars.String.t>,
    rocket_type: null<GraphqlBase.Scalars.String.t>,
    second_stage_block: null<GraphqlBase.Scalars.String.t>,
    semi_major_axis_km: null<GraphqlBase.Scalars.Float.t>,
    ship: null<GraphqlBase.Scalars.String.t>,
    side_core1_reuse: null<GraphqlBase.Scalars.String.t>,
    side_core2_reuse: null<GraphqlBase.Scalars.String.t>,
    site_id: null<GraphqlBase.Scalars.String.t>,
    site_name: null<GraphqlBase.Scalars.String.t>,
    site_name_long: null<GraphqlBase.Scalars.String.t>,
    start: null<GraphqlBase.Scalars.Date.t>,
    tbd: null<GraphqlBase.Scalars.String.t>,
    tentative: null<GraphqlBase.Scalars.String.t>,
    tentative_max_precision: null<GraphqlBase.Scalars.String.t>,
  }
}

module MissionsFind = {
  type t = {
    id: null<GraphqlBase.Scalars.Id.t>,
    manufacturer: null<GraphqlBase.Scalars.String.t>,
    name: null<GraphqlBase.Scalars.String.t>,
    payload_id: null<GraphqlBase.Scalars.String.t>,
  }
}

module PayloadsFind = {
  type t = {
    apoapsis_km: null<GraphqlBase.Scalars.Float.t>,
    customer: null<GraphqlBase.Scalars.String.t>,
    eccentricity: null<GraphqlBase.Scalars.Float.t>,
    epoch: null<GraphqlBase.Scalars.Date.t>,
    inclination_deg: null<GraphqlBase.Scalars.Float.t>,
    lifespan_years: null<GraphqlBase.Scalars.Float.t>,
    longitude: null<GraphqlBase.Scalars.Float.t>,
    manufacturer: null<GraphqlBase.Scalars.String.t>,
    mean_motion: null<GraphqlBase.Scalars.Float.t>,
    nationality: null<GraphqlBase.Scalars.String.t>,
    norad_id: null<GraphqlBase.Scalars.Int.t>,
    orbit: null<GraphqlBase.Scalars.String.t>,
    payload_id: null<GraphqlBase.Scalars.Id.t>,
    payload_type: null<GraphqlBase.Scalars.String.t>,
    periapsis_km: null<GraphqlBase.Scalars.Float.t>,
    period_min: null<GraphqlBase.Scalars.Float.t>,
    raan: null<GraphqlBase.Scalars.Float.t>,
    reference_system: null<GraphqlBase.Scalars.String.t>,
    regime: null<GraphqlBase.Scalars.String.t>,
    reused: null<GraphqlBase.Scalars.Boolean.t>,
    semi_major_axis_km: null<GraphqlBase.Scalars.Float.t>,
  }
}

module ShipsFind = {
  type t = {
    abs: null<GraphqlBase.Scalars.Int.t>,
    active: null<GraphqlBase.Scalars.Boolean.t>,
    attempted_landings: null<GraphqlBase.Scalars.Int.t>,
    class: null<GraphqlBase.Scalars.Int.t>,
    course_deg: null<GraphqlBase.Scalars.Int.t>,
    home_port: null<GraphqlBase.Scalars.String.t>,
    id: null<GraphqlBase.Scalars.Id.t>,
    imo: null<GraphqlBase.Scalars.Int.t>,
    latitude: null<GraphqlBase.Scalars.Float.t>,
    longitude: null<GraphqlBase.Scalars.Float.t>,
    mission: null<GraphqlBase.Scalars.String.t>,
    mmsi: null<GraphqlBase.Scalars.Int.t>,
    model: null<GraphqlBase.Scalars.String.t>,
    name: null<GraphqlBase.Scalars.String.t>,
    role: null<GraphqlBase.Scalars.String.t>,
    speed_kn: null<GraphqlBase.Scalars.Int.t>,
    status: null<GraphqlBase.Scalars.String.t>,
    successful_landings: null<GraphqlBase.Scalars.Int.t>,
    @as("type")
    type_: null<GraphqlBase.Scalars.String.t>,
    weight_kg: null<GraphqlBase.Scalars.Int.t>,
    weight_lbs: null<GraphqlBase.Scalars.Int.t>,
    year_built: null<GraphqlBase.Scalars.Int.t>,
  }
}

module StringComparisonExp = {
  type t = {
    _eq: null<GraphqlBase.Scalars.String.t>,
    _gt: null<GraphqlBase.Scalars.String.t>,
    _gte: null<GraphqlBase.Scalars.String.t>,
    _ilike: null<GraphqlBase.Scalars.String.t>,
    _in: null<array<GraphqlBase.Scalars.String.t>>,
    _is_null: null<GraphqlBase.Scalars.Boolean.t>,
    _like: null<GraphqlBase.Scalars.String.t>,
    _lt: null<GraphqlBase.Scalars.String.t>,
    _lte: null<GraphqlBase.Scalars.String.t>,
    _neq: null<GraphqlBase.Scalars.String.t>,
    _nilike: null<GraphqlBase.Scalars.String.t>,
    _nin: null<array<GraphqlBase.Scalars.String.t>>,
    _nlike: null<GraphqlBase.Scalars.String.t>,
    _nsimilar: null<GraphqlBase.Scalars.String.t>,
    _similar: null<GraphqlBase.Scalars.String.t>,
  }
}

module TimestamptzComparisonExp = {
  type t = {
    _eq: null<GraphqlBase.Scalars.Timestamptz.t>,
    _gt: null<GraphqlBase.Scalars.Timestamptz.t>,
    _gte: null<GraphqlBase.Scalars.Timestamptz.t>,
    _in: null<array<GraphqlBase.Scalars.Timestamptz.t>>,
    _is_null: null<GraphqlBase.Scalars.Boolean.t>,
    _lt: null<GraphqlBase.Scalars.Timestamptz.t>,
    _lte: null<GraphqlBase.Scalars.Timestamptz.t>,
    _neq: null<GraphqlBase.Scalars.Timestamptz.t>,
    _nin: null<array<GraphqlBase.Scalars.Timestamptz.t>>,
  }
}

module UsersInsertInput = {
  type t = {
    id: null<GraphqlBase.Scalars.Uuid.t>,
    name: null<GraphqlBase.Scalars.String.t>,
    rocket: null<GraphqlBase.Scalars.String.t>,
    timestamp: null<GraphqlBase.Scalars.Timestamptz.t>,
    twitter: null<GraphqlBase.Scalars.String.t>,
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
    id: null<GraphqlBase.Scalars.Uuid.t>,
    name: null<GraphqlBase.Scalars.String.t>,
    rocket: null<GraphqlBase.Scalars.String.t>,
    timestamp: null<GraphqlBase.Scalars.Timestamptz.t>,
    twitter: null<GraphqlBase.Scalars.String.t>,
  }
}

module UuidComparisonExp = {
  type t = {
    _eq: null<GraphqlBase.Scalars.Uuid.t>,
    _gt: null<GraphqlBase.Scalars.Uuid.t>,
    _gte: null<GraphqlBase.Scalars.Uuid.t>,
    _in: null<array<GraphqlBase.Scalars.Uuid.t>>,
    _is_null: null<GraphqlBase.Scalars.Boolean.t>,
    _lt: null<GraphqlBase.Scalars.Uuid.t>,
    _lte: null<GraphqlBase.Scalars.Uuid.t>,
    _neq: null<GraphqlBase.Scalars.Uuid.t>,
    _nin: null<array<GraphqlBase.Scalars.Uuid.t>>,
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