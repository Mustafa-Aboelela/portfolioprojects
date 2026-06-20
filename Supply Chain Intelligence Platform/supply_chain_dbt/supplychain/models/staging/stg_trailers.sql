with source as (

    select * from {{ source('supplychain', 'trailers') }}

),

renamed as (
    select 
        trailer_id, 
        trailer_number::int    as trailer_number, 
        trailer_type, 
        length_feet::int       as length_feet, 
        model_year::int        as model_year,
        vin, 
        acquisition_date::date as acquisition_date, 
        status, 
        current_location
    from source
)

select * from renamed
