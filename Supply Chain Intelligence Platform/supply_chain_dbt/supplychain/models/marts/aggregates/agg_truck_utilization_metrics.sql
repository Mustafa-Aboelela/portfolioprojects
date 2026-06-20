with metrics as (

    select *
    from {{ ref('stg_truck_utilization_metrics') }}

),

trucks as (

    select *
    from {{ ref('dim_truck') }}

),

dates as (

    select *
    from {{ ref('dim_date') }}

),

final as (

    select

        -- aggregate fact surrogate key
        {{ dbt_utils.generate_surrogate_key([
            'm.truck_id',
            'm.month'
        ]) }} as truck_utilization_metrics_key,

        -- natural keys
        m.truck_id,
        m.month,

        -- foreign keys
        t.truck_key,
        d.date_key as month_date_key,

        -- measures
        m.trips_completed,
        m.total_miles,
        m.total_revenue,
        m.average_mpg,

        m.maintenance_events,
        m.maintenance_cost,

        m.downtime_hours,
        m.utilization_rate,

        -- derived metrics
        round(
            m.total_revenue /
            nullif(m.trips_completed, 0),
            2
        ) as revenue_per_trip,

        round(
            m.total_miles /
            nullif(m.trips_completed, 0),
            2
        ) as miles_per_trip,

        case
            when m.maintenance_events = 0 then 0
            else round(
                m.maintenance_cost /
                m.maintenance_events,
                2
            )
        end as avg_maintenance_cost_per_event

    from metrics m

    left join trucks t
        on m.truck_id = t.truck_id

    left join dates d
        on d.date_day = m.month

)

select *
from final