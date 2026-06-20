with source as (

    select * from {{ source('supplychain', 'truck_utilization_metrics') }}

),

renamed as (

    select
        truck_id,
        month::date                  as month,
        trips_completed::int          as trips_completed,
        total_miles::int              as total_miles,
        total_revenue::float          as total_revenue,
        average_mpg::float            as average_mpg,
        maintenance_events::int       as maintenance_events,
        maintenance_cost::float       as maintenance_cost,
        downtime_hours::float         as downtime_hours,
        utilization_rate::float       as utilization_rate

    from source

)

select * from renamed