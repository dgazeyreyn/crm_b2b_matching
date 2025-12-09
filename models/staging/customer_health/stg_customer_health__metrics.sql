with source as (

    select * from {{ source('customer_health', 'metrics') }}

),

renamed as (

    select
        tenant_id,
        tenant_company_name,
        customer_segment,
        annual_contract_value,
        data_quality_nps,
        industry

    from source

)

select * from renamed