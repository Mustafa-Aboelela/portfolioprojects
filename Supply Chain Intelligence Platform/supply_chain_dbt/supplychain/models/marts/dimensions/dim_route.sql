with routes as (

    select * from {{ ref('stg_routes') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['route_id']) }}     as route_key,
        route_id,

        origin_city,
        origin_state,

        destination_city,
        destination_state,

        concat(origin_city, ', ', origin_state, ' → ',
               destination_city, ', ', destination_state)   as route_description,

        typical_distance_miles,
        typical_transit_days,
        base_rate_per_mile,
        fuel_surcharge_rate,

        round(base_rate_per_mile * typical_distance_miles, 2)   as estimated_base_revenue,
        case
            when typical_distance_miles < 500   then 'Short Haul'
            when typical_distance_miles < 1500  then 'Medium Haul'
            else 'Long Haul'
        end         as haul_type

    from routes

)

select * from final