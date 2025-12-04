with
    source as (select * from {{ source("companies", "companies") }}),

    renamed as (select zi_company_id, zi_company_name from source)

select *
from renamed
