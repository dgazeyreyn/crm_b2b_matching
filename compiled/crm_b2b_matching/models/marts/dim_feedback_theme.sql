-- models/marts/dim_feedback_theme.sql
with
    src as (select * from `zi-case-study`.`dbt_dreynolds`.`stg_support__themes`),

    final as (

        select distinct
            md5(feedback_theme) as feedback_theme_key,
            feedback_theme,
            current_timestamp() as loaded_at
        from src
    )

select *
from final