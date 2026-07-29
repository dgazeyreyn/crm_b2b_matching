
    
    

with dbt_test__target as (

  select feedback_theme_key as unique_field
  from `zi-case-study`.`dbt_dreynolds`.`dim_feedback_theme`
  where feedback_theme_key is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


