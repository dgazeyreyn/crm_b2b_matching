-- models/marts/dim_company.sql
with
    src as (select * from `zi-case-study`.`dbt_dreynolds`.`stg_zi_companies__companies`),

    final as (

        select
            zi_company_id,
            zi_company_name,
            zi_company_url,
            zi_company_headcount,
            zi_company_country,
            zi_company_city,
            zi_company_region

        from src

    )

select *
from final