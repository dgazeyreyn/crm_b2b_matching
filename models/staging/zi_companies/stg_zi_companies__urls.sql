with source as (

    select * from {{ source('zi_companies', 'urls') }}

),

renamed as (

    select
        zi_company_id,
        zi_company_url

    from source

)

select * from renamed