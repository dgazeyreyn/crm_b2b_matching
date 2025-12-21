{{ config(materialized="table") }}

select
    t.customer_segment,

    sum(h.annual_contract_value) as total_acv,

    sum(h.annual_contract_value * e.affected_match_rate) as exposed_acv,

    safe_divide(
        sum(h.annual_contract_value * e.affected_match_rate),
        sum(h.annual_contract_value)
    ) as pct_acv_exposed

from {{ ref("platinum_tenant_exposure_metrics") }} e
join {{ ref("fact_customer_health") }} h on e.tenant_id = h.tenant_id
join {{ ref("dim_tenant") }} t on e.tenant_id = t.tenant_id

group by t.customer_segment
