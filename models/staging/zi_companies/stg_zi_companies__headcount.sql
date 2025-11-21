with source as (

    select * from {{ source('zi_companies', 'headcount') }}

),

renamed as (

    select
        zi_company_id,
        zi_company_headcount

    from source

)

select * from renamed