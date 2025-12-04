with
    source as (select * from {{ source("customer_health", "customer_health_metrics") }}),

    renamed as (select tenant_id, annual_contract_value from source)

select *
from renamed
