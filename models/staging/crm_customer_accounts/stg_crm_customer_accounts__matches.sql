with source as (

    select * from {{ source('crm_customer_accounts', 'matches') }}

),

renamed as (

    select
        crm_account_id,
        matched_crm_zi_company_id

    from source

)

select * from renamed