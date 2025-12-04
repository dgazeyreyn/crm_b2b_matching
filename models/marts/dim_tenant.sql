with
    tenants as (select * from {{ ref("stg_customer_health__metrics") }}),

    final as (

        select tenant_id, tenant_company_name, customer_segment, industry from tenants

    )

select *
from final
