
    
    

with all_values as (

    select
        feedback_theme as value_field,
        count(*) as n_records

    from `zi-case-study`.`dbt_dreynolds`.`int_support_tickets`
    group by feedback_theme

)

select *
from all_values
where value_field not in (
    'data_completeness','match_accuracy','no_match_found','outdated_company_info','poor_data_quality','wrong_company_matched'
)


