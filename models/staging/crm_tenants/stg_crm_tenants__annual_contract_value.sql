with source as (

    select * from {{ source('crm_tenants', 'annual_contract_value') }}

),

renamed as (

    select
        tenant_id,
        annual_contract_value

    from source

)

select * from renamed