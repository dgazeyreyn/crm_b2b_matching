with
    themes as (select * from `zi-case-study`.`dbt_dreynolds`.`stg_support__themes`),

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

            to_hex(md5(cast(coalesce(cast(tenant_id as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(feedback_theme as string), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ticket_date as string), '_dbt_utils_surrogate_key_null_') as string))) as ticket_id, *
        from dedupe
    )

select *
from final