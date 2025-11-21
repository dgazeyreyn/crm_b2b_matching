with source as (

    select * from {{ source('crm_tenants', 'industries') }}

),

renamed as (

    select
        tenant_id,
        industry

    from source

)

select * from renamed