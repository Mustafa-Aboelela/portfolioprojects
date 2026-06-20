{% snapshot snap_truck %}

{{
    config(
        target_schema='snapshots',
        unique_key='truck_id',
        strategy='check',
        check_cols=[
            'status',
            'home_terminal',
            'fuel_type'
        ]
    )
}}

select
    truck_id,
    unit_number,
    make,
    model_year,
    vin,
    acquisition_date,
    acquisition_mileage,
    fuel_type,
    tank_capacity_gallons,
    status,
    home_terminal

from {{ source('supplychain', 'trucks') }}

{% endsnapshot %}