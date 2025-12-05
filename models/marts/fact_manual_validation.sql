-- models/marts/fact_manual_validation.sql
with
    src as (select * from {{ ref("stg_matching__validation") }}),

    final as (

        select
            crm_account_id,
            zi_company_id,
            manual_validation_result,
            validation_notes,
            validator_name,
            validation_date

        from src

    )

select *
from final
