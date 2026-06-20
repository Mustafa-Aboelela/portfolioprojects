with source as (

    select * from {{ source('supplychain', 'drivers') }}

),

renamed as (

    select
        driver_id,
        first_name,
        last_name,
        hire_date::date           as hire_date,
        termination_date::date    as termination_date,
        license_number,
        license_state,
        date_of_birth::date       as date_of_birth,
        home_terminal,
        employment_status,
        cdl_class,
        years_experience::int     as years_experience

    from source

)

select * from renamed