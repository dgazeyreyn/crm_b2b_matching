-- models/marts/fact_match.sql
with
    src as (select * from `zi-case-study`.`dbt_dreynolds`.`stg_matching__results`),

    final as (

        select
            crm_account_id,
            zi_company_id,
            match_confidence_score,
            match_date,
            algorithm_version

        from src

    )

select *
from final