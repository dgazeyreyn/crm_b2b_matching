with
    tenant_company_exposure as (

        -- Resolve which tenants are exposed to which ZI companies
        select a.tenant_id, m.crm_account_id, m.zi_company_id

        from {{ ref("fact_match") }} m
        join {{ ref("dim_crm_account") }} a on m.crm_account_id = a.crm_account_id
    ),

    tenant_company_quality as (

        -- Attach company quality signals
        select e.tenant_id, e.zi_company_id, cq.city_region_inconsistent

        from tenant_company_exposure e
        join {{ ref("mart_company_quality") }} cq on e.zi_company_id = cq.zi_company_id
    ),

    company_quality_by_tenant as (

        -- Aggregate company quality exposure per tenant
        select
            tenant_id,

            count(distinct zi_company_id) as exposed_company_count,

            sum(
                case when city_region_inconsistent = true then 1 else 0 end
            ) as inconsistent_company_count,

            safe_divide(
                sum(case when city_region_inconsistent = true then 1 else 0 end),
                count(distinct zi_company_id)
            ) as inconsistent_company_exposure_rate

        from tenant_company_quality
        group by tenant_id
    ),

    tenant_trust as (

        -- Trust & commercial context (snapshot)
        select tenant_id, data_quality_nps, annual_contract_value

        from {{ ref("fact_customer_health") }}
    )

select
    t.tenant_id,

    -- Trust indicators
    t.data_quality_nps,
    t.annual_contract_value,

    -- Exposure metrics
    q.exposed_company_count,
    q.inconsistent_company_count,
    q.inconsistent_company_exposure_rate,

    -- Analytical flags / buckets
    case
        when q.inconsistent_company_exposure_rate >= 0.50
        then 'high_exposure'
        when q.inconsistent_company_exposure_rate >= 0.20
        then 'moderate_exposure'
        else 'low_exposure'
    end as company_quality_exposure_band,

    case
        when t.data_quality_nps >= 8
        then 'high_trust'
        when t.data_quality_nps >= 6
        then 'neutral_trust'
        else 'low_trust'
    end as trust_band

from tenant_trust t
left join company_quality_by_tenant q on t.tenant_id = q.tenant_id
