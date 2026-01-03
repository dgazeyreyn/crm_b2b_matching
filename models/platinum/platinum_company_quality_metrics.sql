{{ config(materialized="table") }}

with
    company_quality as (

        select zi_company_id, city_region_inconsistent
        from {{ ref("mart_company_quality") }}
    ),

    final as (

        select
            count(distinct zi_company_id) as companies_evaluated,

            countif(city_region_inconsistent) as city_region_mismatches,

            safe_divide(
                countif(city_region_inconsistent), count(distinct zi_company_id)
            ) as city_region_mismatch_rate

        from company_quality
    )

select *
from final
