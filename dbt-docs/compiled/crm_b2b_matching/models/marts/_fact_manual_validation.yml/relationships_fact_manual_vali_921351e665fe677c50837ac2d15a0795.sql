
    
    

with child as (
    select zi_company_id as from_field
    from `zi-case-study`.`dbt_dreynolds`.`fact_manual_validation`
    where zi_company_id is not null
),

parent as (
    select zi_company_id as to_field
    from `zi-case-study`.`dbt_dreynolds`.`dim_company`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


