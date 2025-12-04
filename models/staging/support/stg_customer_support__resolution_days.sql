with
    source as (select * from {{ source("customer_support", "resolution_days") }}),

    renamed as (select id as ticket_id, resolution_days from source)

select *
from renamed
