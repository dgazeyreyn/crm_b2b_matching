{{ config(materialized="table") }}

with
    company_quality as (

        select mcq.zi_company_id, mcq.city_region_inconsistent
        from {{ ref("mart_company_quality") }} mcq

    ),

    matches as (

        select fm.crm_account_id, fm.zi_company_id from {{ ref("fact_match") }} fm

    ),

    crm_accounts as (

        select crm_account_id, tenant_id from {{ ref("dim_crm_account") }}

    ),

    tenant_company_quality as (

        select
            ca.tenant_id,

            count(*) as total_matched_companies,

            sum(
                case when cq.city_region_inconsistent then 1 else 0 end
            ) as inconsistent_company_count

        from matches m
        join company_quality cq on m.zi_company_id = cq.zi_company_id
        join crm_accounts ca on m.crm_account_id = ca.crm_account_id

        group by ca.tenant_id

    ),

    tenant_trust as (

        select tenant_id, data_quality_nps from {{ ref("fact_customer_health") }}

    ),

    tenants as (

        select tenant_id, tenant_company_name, customer_segment from {{ ref("dim_tenant") }}

    )

select
    t.tenant_id,
    t.tenant_company_name,
    t.customer_segment,

    tcq.total_matched_companies,
    tcq.inconsistent_company_count,

    safe_divide(
        tcq.inconsistent_company_count, tcq.total_matched_companies
    ) as company_quality_defect_rate,

    tt.data_quality_nps,

    case
        when tcq.inconsistent_company_count > 0 and tt.data_quality_nps >= 7
        then 'High Exposure / High Trust'

        when tcq.inconsistent_company_count > 0 and tt.data_quality_nps < 7
        then 'High Exposure / Low Trust'

        when tcq.inconsistent_company_count = 0 and tt.data_quality_nps < 7
        then 'Low Exposure / Low Trust'

        else 'Low Exposure / High Trust'
    end as trust_exposure_category

from tenant_company_quality tcq
join tenants t on tcq.tenant_id = t.tenant_id
left join tenant_trust tt on tcq.tenant_id = tt.tenant_id
