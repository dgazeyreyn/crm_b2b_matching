{{ config(materialized="table") }}

select
    count(distinct zi_company_id) as companies_evaluated,

    countif(city_region_inconsistent) as city_region_mismatches,

    safe_divide(
        countif(city_region_inconsistent), count(distinct zi_company_id)
    ) as city_region_mismatch_rate

from {{ ref("mart_company_quality") }}
