
    
    

with all_values as (

    select
        customer_segment as value_field,
        count(*) as n_records

    from `zi-case-study`.`dbt_dreynolds`.`platinum_support_vs_match_quality_metrics`
    group by customer_segment

)

select *
from all_values
where value_field not in (
    'SMB','MM','ENT'
)


