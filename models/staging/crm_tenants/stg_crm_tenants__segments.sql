with source as (

    select * from {{ source('crm_tenants', 'segments') }}

),

renamed as (

    select
        tenant_id,
        segments

    from source

)

select * from renamed