with customers as (

    select * from {{ ref('stg_customers') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }}  as customer_key,
        customer_id,

        customer_name,
        customer_type,

        contract_start_date,
        datediff('year', contract_start_date, current_date())   as contract_tenure_years,
        credit_terms_days,

        primary_freight_type,

        account_status,
        case when account_status = 'Active'
             then true else false end    as is_active,

        annual_revenue_potential,
        case
            when annual_revenue_potential < 1000000   then 'Small'
            when annual_revenue_potential < 5000000   then 'Medium'
            else 'Large'
        end           as revenue_tier

    from customers

)

select * from final