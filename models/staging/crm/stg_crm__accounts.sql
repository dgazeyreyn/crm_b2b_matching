with source as (

    select * from {{ source('crm', 'accounts') }}

),

renamed as (

    select
        tenant_id,
        tenant_company_name,
        crm_account_id,
        crm_account_name,
        crm_account_url,
        crm_account_country,
        crm_account_region,
        crm_account_headcount

    from source

)

select * from renamed