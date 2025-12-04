with
    source as (select * from {{ source("customer_support", "frequency") }}),

    renamed as (select id as ticket_id, frequency from source)

select *
from renamed
