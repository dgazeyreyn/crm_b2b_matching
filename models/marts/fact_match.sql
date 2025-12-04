with
    results as (select * from {{ ref("stg_matching__results") }}),

    final as (

        select
            crm_account_id,
            zi_company_id,
            match_confidence_score,
            match_date,
            algorithm_version

        from results

    )

select *
from final
