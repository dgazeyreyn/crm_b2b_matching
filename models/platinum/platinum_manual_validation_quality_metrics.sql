{{ config(materialized="table") }}

with
    validations as (

        select
            crm_account_id,
            zi_company_id,
            validation_date,
            manual_validation_result,
            validator_name
        from {{ ref("fact_manual_validation") }}

    ),

    match_context as (

        select crm_account_id, zi_company_id, match_confidence_score, algorithm_version
        from {{ ref("fact_match") }}

    ),

    company_quality as (

        select zi_company_id, city_region_inconsistent
        from {{ ref("mart_company_quality") }}

    ),

    match_quality as (

        select crm_account_id, zi_company_id, match_region_mismatch
        from {{ ref("mart_match_quality") }}

    ),

    crm_context as (select crm_account_id, tenant_id from {{ ref("dim_crm_account") }}),

    tenant_context as (select tenant_id, customer_segment from {{ ref("dim_tenant") }}),

    final as (

        select
            -- Surrogate key
            {{
                dbt_utils.generate_surrogate_key(
                    ["v.crm_account_id", "v.zi_company_id", "v.validation_date"]
                )
            }} as validation_event_id,

            v.validation_date,
            v.validator_name,

            t.customer_segment,

            -- Validator outcome
            case
                when v.manual_validation_result = 'CORRECT'
                then 'correct'
                when v.manual_validation_result = 'INCORRECT'
                then 'incorrect'
                else 'unknown'
            end as validation_outcome,

            v.manual_validation_result = 'CORRECT' as is_validation_correct,
            v.manual_validation_result = 'INCORRECT' as is_validation_incorrect,

            -- Known defects
            coalesce(cq.city_region_inconsistent, false) as city_region_inconsistent,
            coalesce(mq.match_region_mismatch, false) as match_region_mismatch,

            -- Combined defect flag
            (
                coalesce(cq.city_region_inconsistent, false)
                or coalesce(mq.match_region_mismatch, false)
            ) as has_known_defect,

            -- Algorithm context
            mc.match_confidence_score,
            mc.algorithm_version,

            -- Expected outcome based on defects
            case
                when
                    (
                        coalesce(cq.city_region_inconsistent, false)
                        or coalesce(mq.match_region_mismatch, false)
                    )
                then 'incorrect'
                else 'correct'
            end as expected_validation_outcome,

            -- Adjusted correctness (your preferred measure)
            case
                -- True Negative
                when
                    v.manual_validation_result = 'CORRECT'
                    and not (
                        coalesce(cq.city_region_inconsistent, false)
                        or coalesce(mq.match_region_mismatch, false)
                    )
                then 1

                -- True Positive
                when
                    v.manual_validation_result = 'INCORRECT'
                    and (
                        coalesce(cq.city_region_inconsistent, false)
                        or coalesce(mq.match_region_mismatch, false)
                    )
                then 1

                -- Validator incorrect
                else 0
            end as validation_correct_adjusted_flag

        from validations v
        left join
            match_context mc
            on v.crm_account_id = mc.crm_account_id
            and v.zi_company_id = mc.zi_company_id

        left join company_quality cq on v.zi_company_id = cq.zi_company_id

        left join
            match_quality mq
            on v.crm_account_id = mq.crm_account_id
            and v.zi_company_id = mq.zi_company_id

        left join crm_context ca on v.crm_account_id = ca.crm_account_id

        left join tenant_context t on ca.tenant_id = t.tenant_id
    )

select *
from final
