-- models/marts/dim_tenant.sql
with
    src as (select * from {{ ref("stg_customer_health__metrics") }}),

    final as (

        select tenant_id, tenant_company_name, customer_segment, industry from src

    )

select *
from final
