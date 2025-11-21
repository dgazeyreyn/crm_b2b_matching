with source as (

    select * from {{ source('customer_support', 'resolution_days') }}

),

renamed as (

    select
        id,
        resolution_days

    from source

)

select * from renamed