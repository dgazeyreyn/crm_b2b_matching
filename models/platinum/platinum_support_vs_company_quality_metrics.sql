{{ config(materialized="table") }}

with
    company_quality as (
        select city_region_inconsistent, zi_company_id
        from {{ ref("mart_company_quality") }}
    ),

    matches as (select zi_company_id, crm_account_id from {{ ref("fact_match") }}),

    crm as (select tenant_id, crm_account_id from {{ ref("dim_crm_account") }}),

    tenants as (
        select tenant_company_name, customer_segment, tenant_id
        from {{ ref("dim_tenant") }}
    ),

    support_quality as (

        select tenant_id, frequency, is_data_quality_complaint
        from {{ ref("mart_support_quality") }}
    ),

    company_quality_by_tenant as (

        select
            dca.tenant_id,
            dt.tenant_company_name,
            dt.customer_segment,

            count(*) as total_companies_evaluated,

            sum(
                case when mcq.city_region_inconsistent then 1 else 0 end
            ) as city_region_inconsistent_count

        from company_quality mcq

        join matches fm on mcq.zi_company_id = fm.zi_company_id

        join crm dca on fm.crm_account_id = dca.crm_account_id

        join tenants dt on dca.tenant_id = dt.tenant_id

        group by 1, 2, 3
    ),

    support_quality_by_tenant as (

        select
            tenant_id,

            sum(
                case when is_data_quality_complaint then frequency else 0 end
            ) as data_quality_ticket_frequency,

            sum(
                case when is_data_quality_complaint then 1 else 0 end
            ) as data_quality_ticket_count

        from support_quality

        group by 1
    ),

    final as (

        select
            cqt.tenant_id,
            cqt.tenant_company_name,
            cqt.customer_segment,

            cqt.total_companies_evaluated,
            cqt.city_region_inconsistent_count,

            safe_divide(
                cqt.city_region_inconsistent_count, cqt.total_companies_evaluated
            ) as company_quality_defect_rate,

            coalesce(sqt.data_quality_ticket_count, 0) as data_quality_ticket_count,

            coalesce(
                sqt.data_quality_ticket_frequency, 0
            ) as data_quality_ticket_frequency,

            case
                when
                    cqt.city_region_inconsistent_count > 0
                    and coalesce(sqt.data_quality_ticket_frequency, 0) > 0
                then 1
                else 0
            end as support_company_alignment_score

        from company_quality_by_tenant cqt
        left join support_quality_by_tenant sqt on cqt.tenant_id = sqt.tenant_id
    )

select *
from final
