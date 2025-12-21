{{ config(materialized="table") }}

with
    support_match_quality as (

        select
            tenant_id,

            sum(frequency) as total_issue_occurrences,

            sum(
                case when is_match_quality_complaint then frequency else 0 end
            ) as match_quality_issue_occurrences

        from {{ ref("mart_support_quality") }}
        group by tenant_id
    ),

    match_quality as (

        select
            tenant_id,

            count(distinct crm_account_id) as total_accounts_matched,

            sum(
                case when match_region_mismatch = true then 1 else 0 end
            ) as region_mismatch_count,

            safe_divide(
                sum(case when match_region_mismatch = true then 1 else 0 end),
                count(distinct crm_account_id)
            ) as region_mismatch_rate

        from {{ ref("mart_match_quality") }}
        group by tenant_id
    )

select
    coalesce(s.tenant_id, m.tenant_id) as tenant_id,

    /* Support signals */
    s.total_issue_occurrences,
    s.match_quality_issue_occurrences,

    /* Match exposure signals */
    m.total_accounts_matched,
    m.region_mismatch_count,
    m.region_mismatch_rate,

    /* Alignment metrics */
    safe_divide(
        s.match_quality_issue_occurrences, m.region_mismatch_count
    ) as complaints_per_region_mismatch,

    safe_divide(
        s.match_quality_issue_occurrences, m.total_accounts_matched
    ) as match_complaint_intensity,

    /* Diagnostic classification */
    case
        when s.tenant_id is not null and m.tenant_id is not null
        then 'complaint_and_mismatch'
        when s.tenant_id is null and m.tenant_id is not null
        then 'mismatch_no_complaint'
        when s.tenant_id is not null and m.tenant_id is null
        then 'complaint_no_mismatch'
        else 'no_complaint_no_mismatch'
    end as tenant_match_quality_state

from support_match_quality s
full outer join match_quality m on s.tenant_id = m.tenant_id
