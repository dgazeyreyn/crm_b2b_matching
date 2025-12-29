with
    source as (select * from {{ source("zi_companies", "companies") }}),

    renamed as (

        select
            zi_company_id,
            zi_company_name,
            zi_company_url,
            zi_company_headcount,
            zi_company_country,
            zi_company_city,
            zi_company_region

        from source

    )

select *
from renamed
