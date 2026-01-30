





with validation_errors as (

    select
        tenant_id, feedback_theme, ticket_date
    from `zi-case-study`.`dbt_dreynolds`.`int_support_tickets`
    group by tenant_id, feedback_theme, ticket_date
    having count(*) > 1

)

select *
from validation_errors


