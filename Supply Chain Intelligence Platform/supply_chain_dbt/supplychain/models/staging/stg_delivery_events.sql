with source as (

    select * from {{ source('supplychain', 'delivery_events') }}

),

renamed as (

    select
        event_id,
        load_id,
        trip_id,
        event_type,
        facility_id,
        scheduled_datetime::timestamp   as scheduled_datetime,
        actual_datetime::timestamp      as actual_datetime,
        detention_minutes::int          as detention_minutes,
        on_time_flag::boolean           as on_time_flag,
        location_city,
        location_state

    from source

)

select * from renamed