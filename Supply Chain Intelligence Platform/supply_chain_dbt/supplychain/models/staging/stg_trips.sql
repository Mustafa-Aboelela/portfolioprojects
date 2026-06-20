with source as (

    select * from {{ source('supplychain', 'trips') }}

),

renamed as (

    select
        trip_id,
        load_id,
        driver_id,
        truck_id,
        trailer_id,
        dispatch_date::date            as dispatch_date,
        actual_distance_miles::int      as actual_distance_miles,
        actual_duration_hours::float    as actual_duration_hours,
        fuel_gallons_used::float        as fuel_gallons_used,
        average_mpg::float              as average_mpg,
        idle_time_hours::float          as idle_time_hours,
        trip_status

    from source

)

select * from renamed