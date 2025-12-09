-- models/marts/dim_crm_account.sql
with
    src as (select * from {{ ref("stg_crm__accounts") }}),

    final as (

        select
            tenant_id,
            crm_account_id,
            crm_account_name,
            crm_account_url,
            crm_account_country,
            crm_account_region,
            crm_account_headcount

        from src

    )

select *
from final
