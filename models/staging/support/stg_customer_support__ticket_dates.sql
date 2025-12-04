with
    source as (select * from {{ source("customer_support", "ticket_dates") }}),

    renamed as (select id as ticket_id, ticket_date from source)

select *
from renamed
