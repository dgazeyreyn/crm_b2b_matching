
    
    

with child as (
    select tenant_id as from_field
    from `zi-case-study`.`dbt_dreynolds`.`dim_crm_account`
    where tenant_id is not null
),

parent as (
    select tenant_id as to_field
    from `zi-case-study`.`dbt_dreynolds`.`dim_tenant`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


