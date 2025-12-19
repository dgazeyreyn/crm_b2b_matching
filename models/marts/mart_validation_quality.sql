{{ config(materialized="table") }}

with
    source as (

        select
            crm_account_id,
            zi_company_id,
            validation_date,
            manual_validation_result
        from {{ ref("fact_manual_validation") }}

    ),

    standardized as (

        select
            -- Surrogate key: one row per validation event
            {{
                dbt_utils.generate_surrogate_key(
                    ["crm_account_id", "zi_company_id", "validation_date"]
                )
            }} as validation_event_id,

            crm_account_id,
            zi_company_id,

            validation_date as validation_timestamp,

            -- Canonicalized outcome
            case
                when manual_validation_result = 'CORRECT'
                then 'correct'
                when manual_validation_result = 'INCORRECT'
                then 'incorrect'
                else 'unknown'
            end as validation_outcome,

            -- Boolean convenience flags
            manual_validation_result
            = 'INCORRECT' as is_validation_incorrect,

            manual_validation_result = 'CORRECT' as is_validation_correct

        from source

    )

select *
from standardized
