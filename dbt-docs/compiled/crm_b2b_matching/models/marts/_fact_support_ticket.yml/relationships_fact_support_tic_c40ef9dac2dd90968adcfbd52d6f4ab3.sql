
    
    

with child as (
    select feedback_theme_key as from_field
    from `zi-case-study`.`dbt_dreynolds`.`fact_support_ticket`
    where feedback_theme_key is not null
),

parent as (
    select feedback_theme_key as to_field
    from `zi-case-study`.`dbt_dreynolds`.`dim_feedback_theme`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


