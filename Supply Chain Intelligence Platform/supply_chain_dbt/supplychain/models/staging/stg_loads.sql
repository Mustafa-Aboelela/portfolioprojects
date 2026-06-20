with source as (

    select * from {{ source('supplychain', 'loads') }}

),

renamed as (

    select
        load_id,
        customer_id,
        route_id,
        load_date::date                as load_date,
        load_type,
        weight_lbs::int                as weight_lbs,
        pieces::int                    as pieces,
        revenue::float                 as revenue,
        fuel_surcharge::float          as fuel_surcharge,
        accessorial_charges::int       as accessorial_charges,
        load_status,
        booking_type

    from source

)

select * from renamed