with source as (

    select * from {{ source('supplychain', 'safety_incidents') }}

),

renamed as (

    select
        incident_id,
        trip_id,
        truck_id,
        driver_id,
        incident_date::date           as incident_date,
        incident_type,
        location_city,
        location_state,
        at_fault_flag::boolean         as at_fault_flag,
        injury_flag::boolean           as injury_flag,
        vehicle_damage_cost::float     as vehicle_damage_cost,
        cargo_damage_cost::float       as cargo_damage_cost,
        claim_amount::float            as claim_amount,
        preventable_flag::boolean      as preventable_flag,
        description

    from source

)

select * from renamed