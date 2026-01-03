{{ config(materialized="table") }}

with
    match_quality as (

        select
            crm_account_id, zi_company_id, match_confidence_score, match_region_mismatch
        from {{ ref("mart_match_quality") }}

    ),

    company_quality as (

        select zi_company_id, city_region_inconsistent
        from {{ ref("mart_company_quality") }}

    ),

    crm_context as (

        select crm_account_id, tenant_id 
        from {{ ref("dim_crm_account") }}

    ),

    tenant_context as (select tenant_id, tenant_company_name, customer_segment from {{ ref("dim_tenant") }}),

    enriched as (

        select
            mq.crm_account_id,
            mq.zi_company_id,

            crm.tenant_id,
            t.tenant_company_name,
            t.customer_segment,

            mq.match_confidence_score,

            -- Confidence buckets for BI
            case
                when mq.match_confidence_score < 50
                then 'low'
                when mq.match_confidence_score < 80
                then 'medium'
                else 'high'
            end as match_confidence_bucket,

            -- Match-specific defect
            mq.match_region_mismatch,

            -- Company data defect (joined, not owned)
            coalesce(cq.city_region_inconsistent, false) as city_region_inconsistent,

            -- Composite flags
            (
                mq.match_region_mismatch or coalesce(cq.city_region_inconsistent, false)
            ) as has_known_defect,

            -- Defect intensity
            (
                cast(mq.match_region_mismatch as int64)
                + cast(coalesce(cq.city_region_inconsistent, false) as int64)
            ) as defect_count_per_match,

            -- Algorithm overconfidence indicator
            (
                mq.match_confidence_score >= 80
                and (
                    mq.match_region_mismatch
                    or coalesce(cq.city_region_inconsistent, false)
                )
            ) as is_high_confidence_with_defect

        from match_quality mq

        left join company_quality cq on mq.zi_company_id = cq.zi_company_id

        left join crm_context crm on mq.crm_account_id = crm.crm_account_id

        left join tenant_context t on crm.tenant_id = t.tenant_id

    )

select *
from enriched
