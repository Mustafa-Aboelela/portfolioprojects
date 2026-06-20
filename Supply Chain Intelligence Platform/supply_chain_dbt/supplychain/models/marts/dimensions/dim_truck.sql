with trucks as (

    select * from {{ ref('snap_truck') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['truck_id']) }}     as truck_key,
        truck_id,

        unit_number,
        make,
        model_year,
        vin,
        fuel_type,
        tank_capacity_gallons,

        acquisition_date,
        acquisition_mileage,
        datediff('year', acquisition_date, current_date())  as truck_age_years,

        status,
        home_terminal,
        case when status = 'Active'
             then true else false end      as is_active,
        dbt_valid_from                          as valid_from,
        dbt_valid_to                            as valid_to,
        dbt_scd_id                              as truck_scd_key,
        case when dbt_valid_to is null
         then true else false end           as is_current

    from trucks

)

select * from final