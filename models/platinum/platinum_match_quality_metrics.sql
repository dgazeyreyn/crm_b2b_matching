{{ config(materialized="table") }}

select
    date(match_date) as metric_date,
    tenant_id,

    count(distinct crm_account_id) as matched_accounts,

    avg(match_confidence_score) as avg_match_confidence,

    countif(match_confidence_score < 70) as low_confidence_matches,

    safe_divide(
        countif(match_confidence_score < 70), count(distinct crm_account_id)
    ) as low_confidence_match_rate

from {{ ref("mart_match_quality") }}
group by 1, 2