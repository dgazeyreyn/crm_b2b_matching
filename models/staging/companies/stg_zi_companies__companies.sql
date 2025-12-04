with
    source as (select * from {{ source("zi_companies", "companies") }}),

    renamed as (select zi_company_id, zi_company_name from source)

select *
from renamed
