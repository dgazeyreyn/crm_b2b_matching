with
    matches as (select * from {{ ref("int_matching_results") }}),

    crm as (select * from {{ ref("int_crm_customer_accounts") }}),

    zi as (select * from {{ ref("int_zi_companies") }}),

    final as (

        select
            crm.*,
            zi.*,
            matches.match_confidence_score,
            matches.match_date,
            matches.algorithm_version
        from matches
        join crm on matches.crm_account_id = crm.crm_account_id
        join zi on matches.zi_company_id = zi.zi_company_id
    )

select *
from final
