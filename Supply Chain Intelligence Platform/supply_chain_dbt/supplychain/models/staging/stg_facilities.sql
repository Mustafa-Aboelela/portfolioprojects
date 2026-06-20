with source as (

    select * from {{ source('supplychain', 'facilities') }}

),

renamed as (
    select 
        facility_id, 
        facility_name, 
        facility_type, 
        city, 
        state,
        latitude::float     as latitude, 
        longitude::float    as longitude, 
        dock_doors::int     as dock_doors, 
        operating_hours
    from source
)

select * from renamed