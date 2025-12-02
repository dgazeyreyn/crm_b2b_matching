with
    tenants as (select * from {{ ref("stg_crm_tenants__tenants") }}),

    accounts as (select * from {{ ref("stg_crm_customer_accounts__accounts") }}),

    urls as (select * from {{ ref("stg_crm_customer_accounts__urls") }}),

    locations as (select * from {{ ref("stg_crm_customer_accounts__locations") }}),

    headcount as (select * from {{ ref("stg_crm_customer_accounts__headcount") }}),

    final as (

        select
            tenants.*,
            accounts.crm_account_id,
            accounts.crm_account_name,
            urls.crm_account_url,
            locations.crm_account_country,
            locations.crm_account_region,
            headcount.crm_account_headcount
        from accounts
        join tenants on tenants.tenant_id = accounts.tenant_id
        join urls on urls.crm_account_id = accounts.crm_account_id
        join locations on locations.crm_account_id = accounts.crm_account_id
        join headcount on headcount.crm_account_id = accounts.crm_account_id

    )

select *
from final
