

with
    support as (

        select
            st.ticket_id,
            st.tenant_id,
            st.date_key,
            st.feedback_theme_key,
            st.frequency,
            st.avg_severity,
            st.resolution_days

        from `zi-case-study`.`dbt_dreynolds`.`fact_support_ticket` st

    ),

    themes as (

        select feedback_theme_key, feedback_theme from `zi-case-study`.`dbt_dreynolds`.`dim_feedback_theme`

    ),

    tenants as (

        select tenant_id, tenant_company_name, customer_segment
        from `zi-case-study`.`dbt_dreynolds`.`dim_tenant`

    ),

    dates as (select date_key, date from `zi-case-study`.`dbt_dreynolds`.`dim_date`),

    final as (

        select
            -- identifiers
            s.ticket_id,
            s.tenant_id,
            t.tenant_company_name,
            t.customer_segment,

            d.date,
            s.date_key,

            -- ticket attributes
            th.feedback_theme,
            s.frequency,
            s.avg_severity,
            s.resolution_days,

            -- complaint classification flags
            case
                when th.feedback_theme in ('poor_data_quality', 'outdated_company_info')
                then true
                else false
            end as is_data_quality_complaint,

            case
                when
                    th.feedback_theme
                    in ('match_accuracy', 'wrong_company_matched', 'no_match_found')
                then true
                else false
            end as is_match_quality_complaint,

            case
                when
                    th.feedback_theme in (
                        'poor_data_quality',
                        'outdated_company_info',
                        'match_accuracy',
                        'wrong_company_matched',
                        'no_match_found'
                    )
                then true
                else false
            end as is_quality_related_complaint

        from support s
        left join themes th on s.feedback_theme_key = th.feedback_theme_key
        left join tenants t on s.tenant_id = t.tenant_id
        left join dates d on s.date_key = d.date_key

    )

select *
from final