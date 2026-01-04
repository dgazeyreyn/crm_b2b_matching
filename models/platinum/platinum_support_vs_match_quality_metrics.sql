{{ config(materialized="table") }}

with
    match_quality as (select * from {{ ref("mart_match_quality") }}),

    crm as (select tenant_id, crm_account_id from {{ ref("dim_crm_account") }}),

    tenants as (
        select tenant_id, tenant_company_name, customer_segment, annual_contract_value
        from {{ ref("dim_tenant") }}
    ),

    support_quality as (
        select tenant_id, frequency, is_match_quality_complaint, avg_severity
        from {{ ref("mart_support_quality") }}
    ),

    match_quality_only as (

        select
            mq.crm_account_id,
            mq.zi_company_id,

            mq.match_confidence_score,
            mq.match_region_mismatch,

            -- derived match-quality defect flags
            mq.match_region_mismatch as has_known_defect,

            (
                mq.match_confidence_score >= 90 and mq.match_region_mismatch
            ) as is_high_confidence_with_defect

        from match_quality mq
    ),

    match_quality_by_tenant as (

        select
            dca.tenant_id,
            dt.tenant_company_name,
            dt.customer_segment,
            dt.annual_contract_value,

            count(*) as total_matches,

            sum(
                case when match_region_mismatch then 1 else 0 end
            ) as total_defect_matches,

            sum(
                case when is_high_confidence_with_defect then 1 else 0 end
            ) as high_confidence_defect_matches

        from match_quality_only mq
        join crm dca on mq.crm_account_id = dca.crm_account_id
        join tenants dt on dca.tenant_id = dt.tenant_id

        group by 1, 2, 3, 4
    ),

    support_quality_by_tenant as (

        select
            tenant_id,

            sum(frequency) as total_support_incidents,

            sum(
                case when is_match_quality_complaint then frequency else 0 end
            ) as match_quality_complaint_incidents,

            avg(avg_severity) as avg_ticket_severity

        from support_quality
        group by 1
    ),

    final as (

        select
            mq.tenant_id,
            mq.tenant_company_name,
            mq.customer_segment,
            mq.annual_contract_value,

            mq.total_matches,
            mq.total_defect_matches,
            mq.high_confidence_defect_matches,

            sq.total_support_incidents,
            sq.match_quality_complaint_incidents,
            sq.avg_ticket_severity,

            safe_divide(mq.total_defect_matches, mq.total_matches) as defect_rate,

            safe_divide(
                mq.high_confidence_defect_matches, mq.total_matches
            ) as high_confidence_defect_rate,

            safe_divide(
                sq.match_quality_complaint_incidents, mq.total_matches
            ) as complaints_per_match

        from match_quality_by_tenant mq
        left join support_quality_by_tenant sq on mq.tenant_id = sq.tenant_id
    )

select *
from final
