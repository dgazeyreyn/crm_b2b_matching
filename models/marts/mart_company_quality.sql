{{ config(materialized='table') }}

with companies as (
    select *
    from {{ ref('dim_company') }}
),

ref_map as (
    select city, region
    from {{ ref('dim_city_region_ref') }}
),

enriched as (
    select
        {{ dbt_utils.generate_surrogate_key(['zi_company_id']) }} as company_quality_id,
        c.*,
        r.region as expected_region,
        case
            when r.region is null then true
            when lower(trim(c.zi_company_region)) = lower(trim(r.region)) then false
            else true
        end as city_region_inconsistent
    from companies c
    left join ref_map r
      on lower(trim(c.zi_company_city)) = lower(trim(r.city))
)

select *
from enriched