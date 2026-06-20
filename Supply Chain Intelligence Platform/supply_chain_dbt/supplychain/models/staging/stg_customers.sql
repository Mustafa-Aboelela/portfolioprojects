with source as (

    select * from {{ source('supplychain', 'customers') }}

),

renamed as (

    select
        customer_id,
        customer_name,
        customer_type,
        credit_terms_days::int                     as credit_terms_days,
        primary_freight_type,
        account_status,
        contract_start_date::date                   as contract_start_date,
        annual_revenue_potential::number            as annual_revenue_potential

    from source

)

select * from renamed