with source as (

    select * from {{ source('supplychain', 'fuel_purchases') }}

),

renamed as (

    select
        fuel_purchase_id,
        trip_id,
        truck_id,
        driver_id,
        purchase_date::date         as purchase_date,
        location_city,
        location_state,
        gallons::float               as gallons,
        price_per_gallon::float      as price_per_gallon,
        total_cost::float            as total_cost,
        fuel_card_number

    from source

)

select * from renamed