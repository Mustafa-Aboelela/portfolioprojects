with trailers as (

    select * from {{ ref('stg_trailers') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['trailer_id']) }}   as trailer_key,
        trailer_id,

        trailer_number,
        trailer_type,
        length_feet,
        model_year,
        vin,
        datediff('year', acquisition_date, current_date())  as trailer_age_years,

        acquisition_date,
        status,
        current_location,
        case when status = 'Active'
             then true else false end        as is_active

    from trailers

)

select * from final