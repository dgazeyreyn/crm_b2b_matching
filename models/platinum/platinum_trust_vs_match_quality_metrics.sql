{{ config(materialized="table") }}

with
    match_quality as (

        select fm.crm_account_id, fm.match_confidence_score, mq.match_region_mismatch
        from {{ ref("fact_match") }} fm
        join
            {{ ref("mart_match_quality") }} mq
            on fm.crm_account_id = mq.crm_account_id
            and fm.zi_company_id = mq.zi_company_id

    ),

    crm_accounts as (

        select crm_account_id, tenant_id from {{ ref("dim_crm_account") }}

    ),

    tenant_matches as (

        select
            ca.tenant_id,
            count(*) as total_matches,

            -- Matches with known defects
            sum(
                case when mq.match_region_mismatch then 1 else 0 end
            ) as defect_match_count,

            -- Defective matches that still have high confidence
            sum(
                case
                    when mq.match_region_mismatch and mq.match_confidence_score >= 90
                    then 1
                    else 0
                end
            ) as high_confidence_defect_count

        from match_quality mq
        join crm_accounts ca on mq.crm_account_id = ca.crm_account_id

        group by ca.tenant_id

    ),

    tenant_trust as (

        select tenant_id, data_quality_nps from {{ ref("fact_customer_health") }}

    ),

    tenants as (

        select tenant_id, tenant_company_name, customer_segment from {{ ref("dim_tenant") }}

    )

select
    t.tenant_id,
    t.tenant_company_name,
    t.customer_segment,

    tm.total_matches,
    tm.defect_match_count,
    tm.high_confidence_defect_count,

    safe_divide(tm.defect_match_count, tm.total_matches) as defect_rate,

    safe_divide(
        tm.high_confidence_defect_count, tm.total_matches
    ) as high_confidence_defect_rate,

    tt.data_quality_nps,

    case
        when tm.defect_match_count > 0 and tt.data_quality_nps >= 7
        then 'High Exposure / High Trust'

        when tm.defect_match_count > 0 and tt.data_quality_nps < 7
        then 'High Exposure / Low Trust'

        when tm.defect_match_count = 0 and tt.data_quality_nps < 7
        then 'Low Exposure / Low Trust'

        else 'Low Exposure / High Trust'
    end as trust_exposure_category

from tenant_matches tm
join tenants t on tm.tenant_id = t.tenant_id
left join tenant_trust tt on tm.tenant_id = tt.tenant_id
