with
    matches as (select * from {{ ref("int_matching_results") }}),

    crm as (select * from {{ ref("int_crm_customer_accounts") }}),

    zi as (select * from {{ ref("int_zi_companies") }}),

    research as (select * from {{ ref("stg_internal_research__manual_validation_sample") }}),

    final as (

        select
            crm.*,
            zi.*,
            matches.match_confidence_score,
            matches.match_date,
            matches.algorithm_version,
            research.manual_validation_result,
            research.validation_notes,
            research.validator_name,
            research.validation_date
        from matches
        join crm on matches.crm_account_id = crm.crm_account_id
        join zi on matches.zi_company_id = zi.zi_company_id
        left join research on matches.crm_account_id = research.crm_account_id
    )

select *
from final
