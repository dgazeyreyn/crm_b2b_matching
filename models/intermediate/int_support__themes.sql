with
    themes as (select * from {{ ref("stg_support__themes") }}),

    dedupe as (

        select
            tenant_id,
            customer_segment,
            feedback_theme,
            ticket_date,
            sum(frequency) as frequency,
            round(avg(avg_severity), 1) as avg_severity,
            sum(resolution_days) as resolution_days
        from themes
        group by tenant_id, customer_segment, feedback_theme, ticket_date
    ),

    final as (

        select

            {{
                dbt_utils.generate_surrogate_key(
                    ["tenant_id", "feedback_theme", "ticket_date"]
                )
            }} as primary_key, *
        from dedupe
    )

select *
from final
