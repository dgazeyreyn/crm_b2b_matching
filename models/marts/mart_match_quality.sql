-- models/marts/mart_match_quality.sql
{{ config(materialized="table") }}

with
    matches as (
        -- the *actual* algorithmic match output
        select * from {{ ref("fact_match") }}
    ),

    crm as (
        -- CRM account dimensional attributes (region, country, tenant_id)
        select crm_account_id, crm_account_region, crm_account_country, tenant_id
        from {{ ref("dim_crm_account") }}
    ),

    zi as (
        -- ZI company dimensional attributes (region, country)
        select zi_company_id, zi_company_region, zi_company_country
        from {{ ref("dim_company") }}
    ),

    validation as (
        -- manual human validation (optional enrichment)
        select crm_account_id, zi_company_id, manual_validation_result, validation_date
        from {{ ref("fact_manual_validation") }}
    ),

    enriched as (
        select
            -- Surrogate key: uniquely identifies a specific match attempt
            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "m.crm_account_id",
                        "m.zi_company_id",
                        "cast(m.match_date as string)",
                        "m.algorithm_version",
                    ]
                )
            }} as match_quality_id,

            m.*,

            -- bring in CRM attributes
            c.crm_account_region,
            c.crm_account_country,
            c.tenant_id,

            -- bring in ZI attributes
            z.zi_company_region,
            z.zi_company_country,

            -- confidence bucket logic
            case
                when m.match_confidence_score is null
                then 'UNKNOWN'
                when m.match_confidence_score >= 90
                then 'HIGH'
                when m.match_confidence_score >= 60
                then 'MEDIUM'
                else 'LOW'
            end as confidence_bucket,

            case
                when m.match_confidence_score < 60 then true else false
            end as is_low_confidence,

            -- region mismatch: only flag when both present
            case
                when c.crm_account_region is null or z.zi_company_region is null
                then null
                when
                    lower(trim(c.crm_account_region)) = lower(trim(z.zi_company_region))
                then false
                else true
            end as match_region_mismatch,

            -- optional validation fields
            v.manual_validation_result,
            case
                when v.manual_validation_result is not null then true else false
            end as is_validated,
            case
                when v.manual_validation_result in ('INCORRECT', 'no_match')
                then true
                else false
            end as validation_mismatch

        from matches m
        left join crm c on m.crm_account_id = c.crm_account_id
        left join zi z on m.zi_company_id = z.zi_company_id
        left join
            validation v
            on m.crm_account_id = v.crm_account_id
            and m.zi_company_id = v.zi_company_id
    )

select *
from enriched
