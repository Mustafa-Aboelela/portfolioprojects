with incidents as (

    select * from {{ ref('stg_safety_incidents') }}

),

trucks as (

    select * from {{ ref('dim_truck') }}

),

drivers as (

    select * from {{ ref('dim_driver') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        -- fact surrogate key
        {{ dbt_utils.generate_surrogate_key(['i.incident_id']) }}       as safety_incident_key,

        -- natural keys (traceability)
        i.incident_id,
        i.trip_id,
        i.truck_id,
        i.driver_id,

        -- foreign keys (surrogate keys → dimensions)
        tr.truck_key,
        dr.driver_key,
        da.date_key                             as incident_date_key,

        -- degenerate dimensions
        i.incident_type,
        i.location_city,
        i.location_state,
        i.description,

        -- boolean flags (kept as-is for filtering)
        i.at_fault_flag,
        i.injury_flag,
        i.preventable_flag,

        -- boolean flags converted to integers (for aggregation)
        case when i.at_fault_flag    then 1 else 0 end  as at_fault_count,
        case when i.injury_flag      then 1 else 0 end  as injury_count,
        case when i.preventable_flag then 1 else 0 end  as preventable_count,

        -- time context
        i.incident_date,

        -- financial measures
        i.vehicle_damage_cost,
        i.cargo_damage_cost,
        i.claim_amount,

        -- derived measure
        round(
            i.vehicle_damage_cost
            + i.cargo_damage_cost, 2)                   as total_damage_cost

    from incidents i
    left join trucks tr     on tr.truck_id  = i.truck_id
    left join drivers dr    on dr.driver_id = i.driver_id
    left join dates da      on da.date_day  = i.incident_date

)

select * from final