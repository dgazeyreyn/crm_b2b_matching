with source as (

    select * from {{ source('matching_results', 'zi_company_id') }}

),

renamed as (

    select
        crm_account_id,
        zi_company_id

    from source

)

select * from renamed