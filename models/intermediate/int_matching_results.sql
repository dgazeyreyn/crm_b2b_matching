with matches as (

    select * from {{ ref('stg_matching_results__zi_company_id') }}
),

confidence as (

    select * from {{ ref('stg_matching_results__match_confidence_score') }}
),

dates as (

    select * from {{ ref('stg_matching_results__match_date') }}
),

algo_ver as (

    select * from {{ ref('stg_matching_results__algorithm_version') }}
),

final as (

select
    tickets.tenant_id,
    segments.customer_segment,
    themes.feedback_theme,
    frequency.frequency,
    severity.avg_severity,
    dates.ticket_date,
    res_days.resolution_days
from matches
join confidence on confidence.crm_account_id = matches.crm_account_id
join dates on dates.crm_account_id = matches.crm_account_id
join algo_ver on algo_ver.crm_account_id = matches.crm_account_id

)

select * from final