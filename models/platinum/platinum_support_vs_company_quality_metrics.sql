{{ config(materialized="table") }}

with
    company_quality_by_tenant as (

        select
            dca.tenant_id,
            dt.tenant_company_name,
            dt.customer_segment,

            count(*) as total_companies_evaluated,

            sum(
                case when mcq.city_region_inconsistent then 1 else 0 end
            ) as city_region_inconsistent_count

        from {{ ref("mart_company_quality") }} mcq

        join {{ ref("fact_match") }} fm on mcq.zi_company_id = fm.zi_company_id

        join {{ ref("dim_crm_account") }} dca on fm.crm_account_id = dca.crm_account_id

        join {{ ref("dim_tenant") }} dt on dca.tenant_id = dt.tenant_id

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

        from {{ ref("mart_support_quality") }}

        group by 1
    )

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

    coalesce(sqt.data_quality_ticket_frequency, 0) as data_quality_ticket_frequency,

    case
        when
            cqt.city_region_inconsistent_count > 0
            and coalesce(sqt.data_quality_ticket_frequency, 0) > 0
        then 1
        else 0
    end as support_company_alignment_score

from company_quality_by_tenant cqt
left join support_quality_by_tenant sqt on cqt.tenant_id = sqt.tenant_id
