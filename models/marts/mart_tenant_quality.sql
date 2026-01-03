-- models/marts/mart_tenant_quality.sql
{{ config(materialized="table") }}

with
    matches as (select * from {{ ref("mart_match_quality") }}),

    validation as (select * from {{ ref("mart_validation_quality") }}),

    support as (
        select
            tenant_id,
            sum(frequency) as total_support_tickets,
            sum(
                case
                    when
                        feedback_theme
                        in ('match_accuracy', 'wrong_company_matched', 'no_match_found')
                    then frequency
                    else 0
                end
            ) as match_issue_tickets
        from {{ ref("int_support_tickets") }} s
        group by tenant_id
    ),

    crm as (select tenant_id, crm_account_id from {{ ref("dim_crm_account") }}),

    tenant_matches as (
        select
            m.crm_account_id,
            c.tenant_id,
            m.match_quality_id,
            case when m.is_low_confidence then 1 else 0 end as low_confidence_flag,
            case when m.match_region_mismatch then 1 else 0 end as region_mismatch_flag,
            case when m.is_validated then 1 else 0 end as validated_flag,
            case
                when m.validation_mismatch then 1 else 0
            end as validation_incorrect_flag
        from matches m
        left join crm c on m.crm_account_id = c.crm_account_id
    ),

    tenant_agg as (
        select
            tm.tenant_id,
            count(distinct tm.match_quality_id) as total_matches,
            sum(low_confidence_flag) as low_confidence_count,
            sum(region_mismatch_flag) as region_mismatch_count,
            sum(validated_flag) as validated_count,
            sum(validation_incorrect_flag) as validation_incorrect_count
        from tenant_matches tm
        group by 1
    ),

    final as (

        select
            {{ dbt_utils.generate_surrogate_key(["t.tenant_id"]) }}
            as tenant_quality_id,
            t.tenant_id,
            t.total_matches,
            t.low_confidence_count,
            safe_divide(
                t.low_confidence_count, nullif(t.total_matches, 0)
            ) as pct_low_confidence,
            t.region_mismatch_count,
            safe_divide(
                t.region_mismatch_count, nullif(t.total_matches, 0)
            ) as pct_region_mismatch,
            t.validated_count,
            safe_divide(
                t.validation_incorrect_count, nullif(t.validated_count, 0)
            ) as validation_incorrect_rate,
            coalesce(s.total_support_tickets, 0) as total_support_tickets,
            coalesce(s.match_issue_tickets, 0) as match_issue_tickets,
            case
                when coalesce(s.total_support_tickets, 0) > 0
                then
                    safe_divide(
                        coalesce(s.match_issue_tickets, 0), s.total_support_tickets
                    )
                else null
            end as pct_tickets_match_issues
        from tenant_agg t
        left join support s on t.tenant_id = s.tenant_id
    )

select *
from final
