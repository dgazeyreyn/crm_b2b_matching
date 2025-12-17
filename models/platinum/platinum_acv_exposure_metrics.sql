{{ config(materialized="table") }}

select
    p.tenant_id,

    coalesce(h.annual_contract_value, 0) as annual_contract_value,

    p.inconsistency_rate,

    p.trust_risk_level,

    -- ACV-weighted exposure
    coalesce(h.annual_contract_value, 0) * p.inconsistency_rate as acv_at_risk

from {{ ref("platinum_tenant_exposure_metrics") }} p
left join {{ ref("fact_customer_health") }} h on p.tenant_id = h.tenant_id
