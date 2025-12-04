with
    source as (select * from {{ source("zi_companies", "locations") }}),

    renamed as (

        select zi_company_id, zi_company_country, zi_company_city, zi_company_region

        from source

    )

select *
from renamed
