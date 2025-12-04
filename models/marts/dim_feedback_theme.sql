-- models/dim/dim_feedback_theme.sql
with
    src as (select * from {{ ref("stg_support__themes") }}),

    final as (

        select distinct
            md5(feedback_theme) as feedback_theme_key,
            feedback_theme,
            current_timestamp() as loaded_at
        from src
    )

select *
from final
