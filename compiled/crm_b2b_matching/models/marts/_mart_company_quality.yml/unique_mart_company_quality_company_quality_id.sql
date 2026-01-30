
    
    

with dbt_test__target as (

  select company_quality_id as unique_field
  from `zi-case-study`.`dbt_dreynolds`.`mart_company_quality`
  where company_quality_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


