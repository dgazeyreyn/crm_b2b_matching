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
    matches.*,
    confidence.match_confidence_score,
    dates.match_date,
    algo_ver.algorithm_version
from matches
join confidence on confidence.crm_account_id = matches.crm_account_id
join dates on dates.crm_account_id = matches.crm_account_id
join algo_ver on algo_ver.crm_account_id = matches.crm_account_id

)

select * from final