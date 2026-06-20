with drivers as (

    select * from {{ ref('snap_driver') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['driver_id']) }}   as driver_key,
        driver_id,

        concat(first_name, ' ', last_name)  as driver_name,
        first_name,
        last_name,
        date_of_birth,
        datediff('year', date_of_birth, current_date())   as driver_age,

        license_number,
        license_state,
        cdl_class,

        home_terminal,
        employment_status,
        case when employment_status = 'Active' 
             then true else false end         as is_active,
        hire_date,
        termination_date,
        datediff('year', hire_date, current_date())       as tenure_years,
        years_experience,
        case
            when years_experience < 2            then 'Junior'
            when years_experience between 2 and 5 then 'Mid'
            when years_experience between 6 and 10 then 'Senior'
            else 'Veteran'
        end            as experience_band,
        dbt_valid_from      as valid_from,
        dbt_valid_to        as valid_to,
        dbt_scd_id          as driver_scd_key,
        case when dbt_valid_to is null 
        then true else false end    as is_current


    from drivers

)

select * from final