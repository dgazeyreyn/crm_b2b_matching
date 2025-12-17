{{ config(materialized="table") }}

with
    tenant_exposure as (

        select
            e.tenant_id,
            e.affected_match_rate,
            e.company_data_error_rate,
            e.match_alignment_error_rate

        from {{ ref("platinum_tenant_exposure_metrics") }} e
    ),

    tenant_segments as (select tenant_id, customer_segment from {{ ref("dim_tenant") }})

select
    s.customer_segment,

    count(*) as tenant_count,

    avg(e.company_data_error_rate) as avg_company_data_error_rate,
    avg(e.match_alignment_error_rate) as avg_match_alignment_error_rate,
    avg(e.affected_match_rate) as avg_affected_match_rate,

    countif(e.affected_match_rate >= 0.50) as high_risk_tenants

from tenant_exposure e
join tenant_segments s on e.tenant_id = s.tenant_id

group by s.customer_segment
