with source as (

    select * from {{ source('supplychain', 'maintenance_records') }}

),

renamed as (

    select
        maintenance_id,
        truck_id,
        maintenance_date::date     as maintenance_date,
        maintenance_type,
        odometer_reading::int       as odometer_reading,
        labor_hours::float          as labor_hours,
        labor_cost::float           as labor_cost,
        parts_cost::float           as parts_cost,
        total_cost::float           as total_cost,
        facility_location,
        downtime_hours::float       as downtime_hours,
        service_description

    from source

)

select * from renamed