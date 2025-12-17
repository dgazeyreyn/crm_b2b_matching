{{ config(materialized="table") }}

with
    tenant_company_matches as (

        select a.tenant_id, m.zi_company_id

        from {{ ref("fact_match") }} m
        join {{ ref("dim_crm_account") }} a on m.crm_account_id = a.crm_account_id

    ),

    tenant_company_quality as (

        select t.tenant_id, q.city_region_inconsistent

        from tenant_company_matches t
        join {{ ref("mart_company_quality") }} q on t.zi_company_id = q.zi_company_id

    ),

    tenant_metrics as (

        select
            tenant_id,

            count(*) as matched_companies,

            countif(city_region_inconsistent) as inconsistent_companies,

            safe_divide(
                countif(city_region_inconsistent), count(*)
            ) as inconsistency_rate

        from tenant_company_quality
        group by tenant_id
    )

select
    tenant_id,
    matched_companies,
    inconsistent_companies,
    inconsistency_rate,

    -- Extension 3: Trust risk flag
    case
        when inconsistency_rate >= 0.40
        then 'HIGH'
        when inconsistency_rate >= 0.20
        then 'MEDIUM'
        else 'LOW'
    end as trust_risk_level

from tenant_metrics
