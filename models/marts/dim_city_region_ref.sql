-- models/dimensions/dim_city_region_ref.sql
{{ config(materialized='table') }}

select 'Austin' as city, 'Texas' as region union all
select 'Boston', 'Massachusetts' union all
select 'Chicago', 'Illinois' union all
select 'New York', 'New York' union all
select 'San Francisco', 'California' union all
select 'Seattle', 'Washington'