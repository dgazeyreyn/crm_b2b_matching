
    
    

with dbt_test__target as (

  select tenant_id as unique_field
  from `zi-case-study`.`dbt_dreynolds`.`dim_tenant`
  where tenant_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


