
    
    

with dbt_test__target as (

  select crm_account_id as unique_field
  from `zi-case-study`.`dbt_dreynolds`.`stg_matching__validation`
  where crm_account_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


