
    
    

with all_values as (

    select
        manual_validation_result as value_field,
        count(*) as n_records

    from `zi-case-study`.`dbt_dreynolds`.`stg_matching__validation`
    group by manual_validation_result

)

select *
from all_values
where value_field not in (
    'CORRECT','INCORRECT'
)


