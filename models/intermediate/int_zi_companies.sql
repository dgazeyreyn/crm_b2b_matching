with
    companies as (select * from {{ ref("stg_zi_companies__companies") }}),

    urls as (select * from {{ ref("stg_zi_companies__urls") }}),

    headcount as (select * from {{ ref("stg_zi_companies__headcount") }}),

    locations as (select * from {{ ref("stg_zi_companies__locations") }}),

    final as (

        select
            companies.*,
            urls.zi_company_url,
            headcount.zi_company_headcount,
            locations.zi_company_country,
            locations.zi_company_city,
            locations.zi_company_region
        from companies
        join urls on urls.zi_company_id = companies.zi_company_id
        join headcount on headcount.zi_company_id = companies.zi_company_id
        join locations on locations.zi_company_id = companies.zi_company_id

    )

select *
from final
