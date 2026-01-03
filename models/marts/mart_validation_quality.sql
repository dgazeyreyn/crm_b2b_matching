-- mart_validation_quality.sql
-- Purpose: Event-level enrichment of manual validation outcomes.
-- Grain: 1 row per crm_account_id (manual validation event)
with
    base as (
        select
            mv.crm_account_id,
            mv.zi_company_id,
            mv.validation_date,
            mv.manual_validation_result,

            -- normalize result flags
            case
                when upper(mv.manual_validation_result) = 'INCORRECT'
                then true
                else false
            end as is_validation_incorrect,

            case
                when upper(mv.manual_validation_result) = 'CORRECT' then true else false
            end as is_validation_correct

        from {{ ref("fact_manual_validation") }} mv
    ),

    enriched as (
        select
            b.crm_account_id,
            b.zi_company_id,
            b.validation_date,
            b.manual_validation_result,
            b.is_validation_correct,
            b.is_validation_incorrect,

            -- optional descriptive context
            c.zi_company_region,
            c.zi_company_city,
            ca.crm_account_region

        from base b
        left join {{ ref("dim_company") }} c on b.zi_company_id = c.zi_company_id
        left join
            {{ ref("dim_crm_account") }} ca on b.crm_account_id = ca.crm_account_id
    )

select *
from enriched
