{{ config(materialized="table") }}

with
    support_quality as (

        select
            tenant_id,

            /* Volume signals */
            count(distinct ticket_id) as support_ticket_count,
            sum(frequency) as total_issue_occurrences,

            /* Themed issue intensity */
            sum(
                case when is_data_quality_complaint then frequency else 0 end
            ) as data_quality_issue_occurrences

        from {{ ref("mart_support_quality") }}
        group by tenant_id
    ),

    company_quality as (

        select
            a.tenant_id,

            count(distinct c.zi_company_id) as total_companies_seen,

            sum(
                case when c.city_region_inconsistent then 1 else 0 end
            ) as company_region_defect_count,

            safe_divide(
                sum(case when c.city_region_inconsistent then 1 else 0 end),
                count(distinct c.zi_company_id)
            ) as company_region_defect_rate

        from {{ ref("dim_crm_account") }} a
        join {{ ref("fact_match") }} m on a.crm_account_id = m.crm_account_id
        join {{ ref("mart_company_quality") }} c on m.zi_company_id = c.zi_company_id
        group by a.tenant_id
    )

select
    coalesce(s.tenant_id, c.tenant_id) as tenant_id,

    /* Support signals */
    s.support_ticket_count,
    s.total_issue_occurrences,
    s.data_quality_issue_occurrences,

    /* Exposure signals */
    c.total_companies_seen,
    c.company_region_defect_count,
    c.company_region_defect_rate,

    /* Alignment metrics */
    safe_divide(
        s.data_quality_issue_occurrences, c.company_region_defect_count
    ) as data_quality_complaints_per_defect,

    /* Diagnostic classification */
    case
        when s.tenant_id is not null and c.tenant_id is not null
        then 'complaint_and_defect'
        when s.tenant_id is null and c.tenant_id is not null
        then 'defect_no_complaint'
        when s.tenant_id is not null and c.tenant_id is null
        then 'complaint_no_defect'
        else 'no_complaint_no_defect'
    end as tenant_quality_state

from support_quality s
full outer join company_quality c on s.tenant_id = c.tenant_id
