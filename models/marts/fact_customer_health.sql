-- models/dim/fact_customer_health.sql
with
    src as (select * from {{ ref("stg_customer_health__metrics") }}),

    final as (select tenant_id, annual_contract_value, data_quality_nps from src)

select *
from final
