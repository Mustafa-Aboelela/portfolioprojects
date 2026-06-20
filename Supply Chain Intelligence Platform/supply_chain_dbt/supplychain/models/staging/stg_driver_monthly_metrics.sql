with source as (

    select * from {{ source('supplychain', 'driver_monthly_metrics') }}

),

renamed as (

    select
        driver_id,
        month::date                     as month,
        trips_completed::int             as trips_completed,
        total_miles::int                 as total_miles,
        total_revenue::float             as total_revenue,
        average_mpg::float                as average_mpg,
        total_fuel_gallons::float         as total_fuel_gallons,
        on_time_delivery_rate::float      as on_time_delivery_rate,
        average_idle_hours::float         as average_idle_hours

    from source

)

select * from renamed