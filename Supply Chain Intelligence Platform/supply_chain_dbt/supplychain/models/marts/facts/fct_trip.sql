with trips as (

    select * from {{ ref('stg_trips') }}

),

loads as (

    select * from {{ ref('stg_loads') }}

),

fuel as (

    select
        trip_id,
        sum(total_cost)     as total_fuel_cost,
        sum(gallons)        as total_fuel_gallons
    from {{ ref('stg_fuel_purchases') }}
    group by trip_id

),

drivers as (

    select * from {{ ref('dim_driver') }}

),

trucks as (

    select * from {{ ref('dim_truck') }}

),

trailers as (

    select * from {{ ref('dim_trailer') }}

),

customers as (

    select * from {{ ref('dim_customer') }}

),

routes_dim as (

    select * from {{ ref('dim_route') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        -- fact surrogate key
        {{ dbt_utils.generate_surrogate_key(['t.trip_id']) }}   as trip_key,

        -- natural key
        t.trip_id,

        -- dimension foreign keys (surrogate keys)
        d.driver_key,
        tr.truck_key,
        tl.trailer_key,
        c.customer_key,
        rd.route_key,
        dt.date_key                 as dispatch_date_key,

        -- degenerate dimensions
        t.trip_status,
        l.load_type,
        l.booking_type,

        -- operational attributes
        l.weight_lbs,
        l.pieces,

        -- distance & time measures
        t.actual_distance_miles,
        t.actual_duration_hours,
        t.idle_time_hours,
        rd.typical_distance_miles,
        t.actual_distance_miles
            - rd.typical_distance_miles       as distance_variance_miles,

        -- revenue measures
        l.revenue,
        l.fuel_surcharge,
        l.accessorial_charges,
        l.revenue
            + l.fuel_surcharge
            + l.accessorial_charges             as total_revenue,

        -- fuel measures
        t.fuel_gallons_used,
        t.average_mpg,
        coalesce(f.total_fuel_cost, 0)            as total_fuel_cost,
        coalesce(f.total_fuel_gallons, 0)              as total_fuel_gallons,

        -- derived KPIs
        round(
            (l.revenue + l.fuel_surcharge + l.accessorial_charges)
            / nullif(t.actual_distance_miles, 0), 2)            as revenue_per_mile,
        round(
            coalesce(f.total_fuel_cost, 0)
            / nullif(t.actual_distance_miles, 0), 2)            as fuel_cost_per_mile,
        round(
            (l.revenue + l.fuel_surcharge + l.accessorial_charges)
            - coalesce(f.total_fuel_cost, 0), 2)                as gross_margin

    from trips t
    left join loads l           on l.load_id        = t.load_id
    left join fuel f            on f.trip_id        = t.trip_id
    left join drivers d         on d.driver_id      = t.driver_id
    left join trucks tr         on tr.truck_id      = t.truck_id
    left join trailers tl       on tl.trailer_id    = t.trailer_id
    left join customers c       on c.customer_id    = l.customer_id
    left join routes_dim rd     on rd.route_id      = l.route_id
    left join dates dt          on dt.date_day      = t.dispatch_date

)

select * from final