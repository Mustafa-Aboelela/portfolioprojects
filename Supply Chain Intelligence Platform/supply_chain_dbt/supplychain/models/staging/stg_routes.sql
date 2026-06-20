with source as (

    select * from {{ source('supplychain', 'routes') }}

),

renamed as (

    select
        route_id,
        origin_city,
        origin_state,
        destination_city,
        destination_state,
        typical_distance_miles::int    as typical_distance_miles,
        base_rate_per_mile::float      as base_rate_per_mile,
        fuel_surcharge_rate::float     as fuel_surcharge_rate,
        typical_transit_days::int      as typical_transit_days

    from source

)

select * from renamed