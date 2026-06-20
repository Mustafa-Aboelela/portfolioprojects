with delivery_events as (

    select * from {{ ref('stg_delivery_events') }}

),

loads as (

    select * from {{ ref('stg_loads') }}

),

facilities as (

    select * from {{ ref('dim_facility') }}

),

customers as (

    select * from {{ ref('dim_customer') }}

),

routes as (

    select * from {{ ref('dim_route') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        -- fact surrogate key
        {{ dbt_utils.generate_surrogate_key(['de.event_id']) }}     as delivery_event_key,

        -- natural key
        de.event_id,

        -- foreign keys (surrogate keys → dimensions)
        f.facility_key,
        c.customer_key,
        r.route_key,
        dt.date_key                       as event_date_key,

        -- degenerate dimensions
        de.event_type,                  -- 'Pickup' or 'Delivery'
        l.load_type,
        l.load_status,

        -- natural keys kept for traceability
        de.load_id,
        de.trip_id,

        -- time measures
        de.scheduled_datetime,
        de.actual_datetime,
        datediff(
            'minute',
            de.scheduled_datetime,
            de.actual_datetime
        )   as arrival_variance_minutes,

        -- performance measures
        de.detention_minutes,
        de.on_time_flag,
        case when de.on_time_flag then 1 else 0 end         as on_time_count,

        -- location context
        de.location_city,
        de.location_state

    from delivery_events de
    left join loads l       on l.load_id        = de.load_id
    left join facilities f  on f.facility_id    = de.facility_id
    left join customers c   on c.customer_id    = l.customer_id
    left join routes r      on r.route_id       = l.route_id
    left join dates dt      on dt.date_day      = de.actual_datetime::date

)

select * from final