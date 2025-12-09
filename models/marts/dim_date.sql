-- models/marts/dim_date.sql
with
    src as (select * from {{ ref("int_support_tickets") }}),

    -- Get min/max date from support themes staging model
    bounds as (
        select min(ticket_date) as min_date, max(ticket_date) as max_date from src
    ),

    date_range as (
        select day
        from
            bounds,
            unnest(generate_date_array(min_date, max_date, interval 1 day)) as day
    ),

    final as (

        select
            cast(format_date('%Y%m%d', day) as int64) as date_key,
            day as date,
            extract(year from day) as year,
            extract(quarter from day) as quarter,
            extract(month from day) as month,
            extract(day from day) as day_of_month,
            extract(week from day) as week_of_year,
            extract(dayofweek from day) as day_of_week,
            extract(isoweek from day) as iso_week,
            extract(isoyear from day) as iso_year,
            format_date('%A', day) as weekday_name,
            format_date('%B', day) as month_name,
            (extract(dayofweek from day) in (1, 7)) as is_weekend
        from date_range
        order by day
    )

select *
from final
