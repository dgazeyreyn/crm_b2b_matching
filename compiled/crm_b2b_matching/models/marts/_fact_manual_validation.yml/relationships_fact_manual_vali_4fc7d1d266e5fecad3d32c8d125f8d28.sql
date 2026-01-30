
    
    

with child as (
    select crm_account_id as from_field
    from `zi-case-study`.`dbt_dreynolds`.`fact_manual_validation`
    where crm_account_id is not null
),

parent as (
    select crm_account_id as to_field
    from `zi-case-study`.`dbt_dreynolds`.`dim_crm_account`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


