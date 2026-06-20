{% snapshot snap_driver %}

{{
    config(
        target_schema='snapshots',
        unique_key='driver_id',
        strategy='check',
        check_cols=[
            'home_terminal',
            'employment_status',
            'cdl_class',
            'license_state'
        ]
    )
}}

select
    driver_id,
    first_name,
    last_name,
    date_of_birth,
    license_number,
    license_state,
    cdl_class,
    home_terminal,
    employment_status,
    hire_date,
    termination_date,
    years_experience

from {{ source('supplychain', 'drivers') }}

{% endsnapshot %}