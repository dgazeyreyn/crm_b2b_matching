
    
    

with dbt_test__target as (

  select zi_company_id as unique_field
  from `zi-case-study`.`dbt_dreynolds`.`dim_company`
  where zi_company_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


