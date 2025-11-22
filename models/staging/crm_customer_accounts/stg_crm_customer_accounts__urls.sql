with source as (

    select * from {{ source('crm_customer_accounts', 'urls') }}

),

renamed as (

    select
        crm_account_id,
        crm_account_url

    from source

)

select * from renamed