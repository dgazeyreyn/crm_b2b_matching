

with companies as (
    select *
    from `zi-case-study`.`dbt_dreynolds`.`dim_company`
),

ref_map as (
    select city, region
    from `zi-case-study`.`dbt_dreynolds`.`dim_city_region_ref`
),

enriched as (
    select
        to_hex(md5(cast(coalesce(cast(zi_company_id as string), '_dbt_utils_surrogate_key_null_') as string))) as company_quality_id,
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