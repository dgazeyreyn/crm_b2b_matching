-- models/marts/dim_tenant.sql
with
    src as (select * from `zi-case-study`.`dbt_dreynolds`.`stg_customer_health__metrics`),

    final as (

        select
            tenant_id,
            tenant_company_name,
            customer_segment,
            industry,
            annual_contract_value
        from src

    )

select *
from final