{{ config(materialized="table") }}

with
    exposure as (

        select affected_match_rate, tenant_id
        from {{ ref("platinum_tenant_exposure_metrics") }}
    ),

    health as (
        select annual_contract_value, tenant_id from {{ ref("fact_customer_health") }}
    ),

    tenants as (select tenant_id, customer_segment from {{ ref("dim_tenant") }}),

    final as (

        select
            t.customer_segment,

            sum(h.annual_contract_value) as total_acv,

            sum(h.annual_contract_value * e.affected_match_rate) as exposed_acv,

            safe_divide(
                sum(h.annual_contract_value * e.affected_match_rate),
                sum(h.annual_contract_value)
            ) as pct_acv_exposed

        from exposure e
        join health h on e.tenant_id = h.tenant_id
        join tenants t on e.tenant_id = t.tenant_id

        group by t.customer_segment
    )

select *
from final
