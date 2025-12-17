{{ config(materialized="table") }}

select
    t.customer_segment,

    count(*) as tenant_count,
    avg(p.inconsistency_rate) as avg_inconsistency_rate,
    avg(p.matched_companies) as avg_matched_companies,

    countif(p.trust_risk_level = 'HIGH') as high_risk_tenants

from {{ ref("platinum_tenant_exposure_metrics") }} p
join {{ ref("dim_tenant") }} t on p.tenant_id = t.tenant_id

group by t.customer_segment
