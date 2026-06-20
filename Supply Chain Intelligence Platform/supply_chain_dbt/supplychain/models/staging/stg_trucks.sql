with source as (

    select * from {{ source('supplychain', 'trucks') }}

),

renamed as (
    select 
        truck_id,
        unit_number::int             as unit_number,
        make, 
        model_year::int              as model_year,
        vin, 
        acquisition_date::date       as acquisition_date,
        acquisition_mileage::int     as acquisition_mileage, 
        fuel_type, 
        tank_capacity_gallons::int   as tank_capacity_gallons , 
        status, 
        home_terminal
    from source
)

select * from renamed