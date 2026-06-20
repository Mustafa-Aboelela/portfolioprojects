
with fuel_purchases as (

    select * from {{ ref('stg_fuel_purchases') }}

),

trucks as (

    select * from {{ ref('dim_truck') }}

),
drivers as (

    select * from {{ ref('dim_driver') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        
        -- fact surrogate key
        {{ dbt_utils.generate_surrogate_key(['fu.fuel_purchase_id']) }}     as fuel_purchase_key,
        
        -- natrul key (bussiness key)
        fu.fuel_purchase_id,
        fu.trip_id,    -- traceability back to stg_trips
        
        -- forein key
        tr.truck_key,
        dr.driver_key,
        da.date_key      as fuel_purchase_date_key,

        -- degenerate dimensions
        fu.location_city,
        fu.location_state,
        fu.fuel_card_number,

        --time measurs
        fu.purchase_date,

        --measurs
        fu.gallons,
        fu.total_cost,
        fu.price_per_gallon   


    from fuel_purchases  fu   
    left join  trucks  tr     on fu.truck_id =tr.truck_id 
    left join  drivers dr     on fu.driver_id = dr.driver_id
    left join  dates da       on fu.purchase_date = da.date_day
)
select * from final