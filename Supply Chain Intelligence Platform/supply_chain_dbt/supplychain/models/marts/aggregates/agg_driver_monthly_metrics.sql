with metrics as (

    select *
    from {{ ref('stg_driver_monthly_metrics') }}

),

drivers as (

    select *
    from {{ ref('dim_driver') }}

),

dates as (

    select *
    from {{ ref('dim_date') }}

),

final as (

    select

        -- aggregate fact surrogate key
        {{ dbt_utils.generate_surrogate_key([
            'm.driver_id',
            'm.month'
        ]) }} as driver_monthly_metrics_key,

        -- natural keys
        m.driver_id,
        m.month,

        -- foreign keys
        d.driver_key,
        dt.date_key as month_date_key,

        -- measures
        m.trips_completed,
        m.total_miles,
        m.total_revenue,
        m.total_fuel_gallons,
        m.average_mpg,
        m.on_time_delivery_rate,
        m.average_idle_hours,

        -- derived KPIs
        round(
            m.total_revenue /
            nullif(m.trips_completed,0),
            2
        ) as revenue_per_trip,

        round(
            m.total_miles /
            nullif(m.total_fuel_gallons,0),
            2
        ) as calculated_mpg

    from metrics m

    left join drivers d
        on m.driver_id = d.driver_id

    left join dates dt
        on dt.date_day = m.month

)

select *
from final