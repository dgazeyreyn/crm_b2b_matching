-- models/dimensions/dim_city_region_ref.sql
{{ config(materialized='table') }}

select 'Austin'        as zi_company_city, 'Texas'         as region union all
select 'Boston'        as zi_company_city, 'Massachusetts' as region union all
select 'Chicago'       as zi_company_city, 'Illinois'      as region union all
select 'New York'      as zi_company_city, 'New York'      as region union all
select 'San Francisco' as zi_company_city, 'California'    as region union all
select 'Seattle'       as zi_company_city, 'Washington'    as region
