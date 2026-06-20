{{ config(materialized='table') }}

with date_spine as (

    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('2022-01-01' as date)",
            end_date="cast('2027-12-31' as date)"
        )
    }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['date_day']) }}     as date_key,
        -- primary key
        cast(date_day as date)                              as date_day,

        -- year
        year(date_day)                                      as year,

        -- quarter
        quarter(date_day)                                   as quarter_number,
        'Q' || quarter(date_day)                            as quarter,

        -- month
        month(date_day)                                     as month_number,
        monthname(date_day)                                 as month_name,

        -- week
        weekofyear(date_day)                                as week_number,

        -- day
        day(date_day)                                       as day_of_month,
        dayofyear(date_day)                                 as day_of_year,
        dayofweek(date_day)                                 as day_of_week_num,
        dayname(date_day)                                   as day_of_week,

        -- flags
        case when dayofweek(date_day) in (1, 7)
             then true else false end                        as is_weekend,
        case when dayofweek(date_day) in (1, 7)
             then false else true end                        as is_weekday,

        -- relative helpers (useful for BI tools)
        case when cast(date_day as date) = current_date()
             then true else false end                        as is_today,
        case when year(date_day) = year(current_date())
             then true else false end                        as is_current_year,
        case when year(date_day) = year(current_date())
             and quarter(date_day) = quarter(current_date())
             then true else false end                        as is_current_quarter,
        case when year(date_day) = year(current_date())
             and month(date_day) = month(current_date())
             then true else false end                        as is_current_month

    from date_spine

)

select * from final