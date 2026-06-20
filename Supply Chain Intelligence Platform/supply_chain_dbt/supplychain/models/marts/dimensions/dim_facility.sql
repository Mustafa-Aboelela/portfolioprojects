with facilities as (

    select * from {{ ref('stg_facilities') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['facility_id']) }}  as facility_key,
        facility_id,

        facility_name,
        facility_type,

        city,
        state,
        latitude,
        longitude,

        dock_doors,
        operating_hours

    from facilities

)

select * from final