{{ config(materialized="table") }}

with
    validations as (

        select
            validation_event_id,
            crm_account_id,
            zi_company_id,
            validation_timestamp,
            validation_outcome,
            is_validation_correct,
            is_validation_incorrect
        from {{ ref("mart_validation_quality") }}

    ),

    company_defects as (

        select zi_company_id, city_region_inconsistent
        from {{ ref("mart_company_quality") }}

    ),

    match_defects as (

        select crm_account_id, zi_company_id, match_region_mismatch
        from {{ ref("mart_match_quality") }}

    ),

    joined as (

        select
            v.validation_event_id,
            v.validation_timestamp,

            -- Validator outcome
            v.validation_outcome,
            v.is_validation_correct,
            v.is_validation_incorrect,

            -- Known defects
            coalesce(c.city_region_inconsistent, false) as city_region_inconsistent,

            coalesce(
                m.match_region_mismatch, false
            ) as crm_company_region_mismatch,

            -- Composite defect flag
            (
                coalesce(c.city_region_inconsistent, false)
                or coalesce(m.match_region_mismatch, false)
            ) as has_known_defect

        from validations v
        left join company_defects c on v.zi_company_id = c.zi_company_id
        left join
            match_defects m
            on v.crm_account_id = m.crm_account_id
            and v.zi_company_id = m.zi_company_id

    ),

    evaluated as (

        select
            *,

            -- Validation marked correct despite known defect
            case
                when is_validation_correct = true and has_known_defect = true
                then true
                else false
            end as false_positive_validation,

            -- Validation correctly flagged a bad record
            case
                when is_validation_incorrect = true and has_known_defect = true
                then true
                else false
            end as true_positive_validation

        from joined

    )

select
    -- Time
    date(validation_timestamp) as validation_date,

    -- Volumes
    count(*) as validation_count,

    -- Outcomes
    sum(cast(is_validation_correct as int64)) as correct_validation_count,

    sum(cast(is_validation_incorrect as int64)) as incorrect_validation_count,

    -- Defect exposure
    sum(cast(has_known_defect as int64)) as validations_with_known_defects,

    -- Validator performance vs defects
    sum(cast(false_positive_validation as int64)) as false_positive_validation_count,

    sum(cast(true_positive_validation as int64)) as true_positive_validation_count,

    -- Rates
    safe_divide(
        sum(cast(false_positive_validation as int64)),
        sum(cast(has_known_defect as int64))
    ) as false_positive_validation_rate,

    safe_divide(
        sum(cast(true_positive_validation as int64)),
        sum(cast(has_known_defect as int64))
    ) as true_positive_validation_rate

from evaluated
group by validation_date
