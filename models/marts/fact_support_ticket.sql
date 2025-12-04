-- models/marts/fact_support_ticket.sql
with
    src as (select * from {{ ref("int_support_ticket") }}),

    theme as (select * from {{ ref("dim_feedback_theme") }}),

    tickets as (
        select
            ticket_id,
            tenant_id,
            feedback_theme,
            ticket_date,
            frequency,
            avg_severity,
            resolution_days
        from src
    ),

    -- ensure canonical theme key
    theme_key as (
        select
            feedback_theme as feedback_theme, md5(feedback_theme) as feedback_theme_key  -- or a surrogate
        from theme
    ),

    final as (
        select
            s.ticket_id,
            s.tenant_id,
            t.feedback_theme_key,
            cast(format_date('%Y%m%d', s.ticket_date) as int64) as date_key,
            s.frequency,
            s.avg_severity,
            s.resolution_days,
            current_timestamp() as updated_at
        from tickets s
        left join theme_key t on s.feedback_theme = t.feedback_theme
    )

select *
from final
