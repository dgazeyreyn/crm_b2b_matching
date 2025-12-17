{{ config(materialized="table") }}

with
    matches as (

        select m.crm_account_id, m.zi_company_id, a.tenant_id

        from {{ ref("fact_match") }} m
        join {{ ref("dim_crm_account") }} a on m.crm_account_id = a.crm_account_id
    ),

    company_quality as (

        select zi_company_id, city_region_inconsistent
        from {{ ref("mart_company_quality") }}
    ),

    match_alignment as (

        select crm_account_id, zi_company_id, region_mismatch
        from {{ ref("mart_match_alignment_quality") }}
    ),

    combined as (

        select
            m.tenant_id,
            m.crm_account_id,
            m.zi_company_id,

            coalesce(c.city_region_inconsistent, false) as company_inconsistent,
            coalesce(a.region_mismatch, false) as region_mismatch

        from matches m
        left join company_quality c on m.zi_company_id = c.zi_company_id
        left join
            match_alignment a
            on m.crm_account_id = a.crm_account_id
            and m.zi_company_id = a.zi_company_id
    )

select
    tenant_id,

    count(*) as total_matches,

    countif(company_inconsistent) as company_data_errors,
    countif(region_mismatch) as match_alignment_errors,

    countif(company_inconsistent or region_mismatch) as affected_matches,

    countif(company_inconsistent and region_mismatch) as compound_failures,

    safe_divide(countif(company_inconsistent), count(*)) as company_data_error_rate,

    safe_divide(countif(region_mismatch), count(*)) as match_alignment_error_rate,

    safe_divide(
        countif(company_inconsistent or region_mismatch), count(*)
    ) as affected_match_rate,

    safe_divide(
        countif(company_inconsistent and region_mismatch), count(*)
    ) as compound_error_rate,

    case
        when
            safe_divide(countif(company_inconsistent or region_mismatch), count(*))
            >= 0.50
        then 'HIGH'
        when
            safe_divide(countif(company_inconsistent or region_mismatch), count(*))
            >= 0.20
        then 'MEDIUM'
        else 'LOW'
    end as trust_risk_level

from combined
group by tenant_id
