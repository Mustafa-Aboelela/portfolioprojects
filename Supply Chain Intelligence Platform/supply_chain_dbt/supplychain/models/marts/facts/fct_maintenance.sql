with maintenance as (

    select * from {{ ref('stg_maintenance_records') }}

),

trucks as (

    select * from {{ ref('dim_truck') }}

),

dates as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        -- fact surrogate key
        {{ dbt_utils.generate_surrogate_key(['m.maintenance_id']) }}    as maintenance_key,

        -- natural key (traceability)
        m.maintenance_id,
        m.truck_id,

        -- foreign keys (surrogate keys → dimensions)
        tr.truck_key,
        da.date_key                         as maintenance_date_key,

        -- degenerate dimensions
        m.maintenance_type,
        m.facility_location,
        m.service_description,

        -- semi-additive fact
        m.odometer_reading,

        -- time measures
        m.maintenance_date,

        -- cost measures
        m.labor_hours,
        m.labor_cost,
        m.parts_cost,
        m.total_cost,

        -- operational measures
        m.downtime_hours

    from maintenance m
    left join trucks tr     on tr.truck_id  = m.truck_id
    left join dates da      on da.date_day  = m.maintenance_date

)

select * from final