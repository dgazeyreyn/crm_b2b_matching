with source as (

    select * from {{ source('customer_support', 'tickets') }}

),

renamed as (

    select
        id,
        tenant_id

    from source

)

select * from renamed