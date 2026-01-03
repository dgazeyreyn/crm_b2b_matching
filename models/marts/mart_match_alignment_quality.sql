{{ config(materialized="table") }}

with
    matches as (select crm_account_id, zi_company_id from {{ ref("fact_match") }}),

    crm as (
        select tenant_id, crm_account_region, crm_account_id
        from {{ ref("dim_crm_account") }}
    ),

    zi as (select zi_company_region, zi_company_id from {{ ref("dim_company") }}),

    final as (

        select
            m.crm_account_id,
            m.zi_company_id,

            a.tenant_id,

            a.crm_account_region as crm_region,
            c.zi_company_region as company_region,

            case
                when a.crm_account_region = c.zi_company_region then false else true
            end as region_mismatch,

            current_timestamp() as loaded_at

        from matches m
        join crm a on m.crm_account_id = a.crm_account_id
        join zi c on m.zi_company_id = c.zi_company_id
    )

select *
from final
