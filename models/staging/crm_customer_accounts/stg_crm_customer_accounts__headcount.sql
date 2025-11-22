with source as (

    select * from {{ source('crm_customer_accounts', 'headcount') }}

),

renamed as (

    select
        crm_account_id,
        crm_account_headcount

    from source

)

select * from renamed