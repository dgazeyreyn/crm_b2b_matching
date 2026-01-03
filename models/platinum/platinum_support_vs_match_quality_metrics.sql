{{ config(materialized="table") }}

with
    match_plus_company_quality as (

        select
            mq.crm_account_id,
            mq.zi_company_id,

            mq.match_confidence_score,
            mq.match_region_mismatch,

            -- company quality enrichment
            cq.city_region_inconsistent,

            -- derived defect flags
            (
                mq.match_region_mismatch or cq.city_region_inconsistent
            ) as has_known_defect,

            (
                mq.match_confidence_score >= 90
                and (mq.match_region_mismatch or cq.city_region_inconsistent)
            ) as is_high_confidence_with_defect

        from {{ ref("mart_match_quality") }} mq
        left join
            {{ ref("mart_company_quality") }} cq on mq.zi_company_id = cq.zi_company_id
    ),

    match_quality_by_tenant as (

        select
            dca.tenant_id,
            dt.tenant_company_name,
            dt.customer_segment,

            count(*) as total_matches,

            sum(
                case when match_region_mismatch then 1 else 0 end
            ) as region_mismatch_count,

            sum(
                case when city_region_inconsistent then 1 else 0 end
            ) as company_data_defect_count,

            sum(case when has_known_defect then 1 else 0 end) as total_defect_matches,

            sum(
                case when is_high_confidence_with_defect then 1 else 0 end
            ) as high_confidence_defect_matches

        from match_plus_company_quality mpq
        join {{ ref("dim_crm_account") }} dca on mpq.crm_account_id = dca.crm_account_id
        join {{ ref("dim_tenant") }} dt on dca.tenant_id = dt.tenant_id

        group by 1, 2, 3
    ),

    support_quality_by_tenant as (

        select
            tenant_id,

            sum(frequency) as total_support_incidents,

            sum(
                case when is_match_quality_complaint then frequency else 0 end
            ) as match_quality_complaint_incidents,

            avg(avg_severity) as avg_ticket_severity

        from {{ ref("mart_support_quality") }}
        group by 1
    )

select
    mq.tenant_id,
    mq.tenant_company_name,
    mq.customer_segment,

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
