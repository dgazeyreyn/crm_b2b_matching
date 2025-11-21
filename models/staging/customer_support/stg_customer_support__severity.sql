with source as (

    select * from {{ source('customer_support', 'severity') }}

),

renamed as (

    select
        id,
        avg_severity

    from source

)

select * from renamed