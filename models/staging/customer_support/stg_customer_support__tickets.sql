with
    source as (select * from {{ source("customer_support", "tickets") }}),

    renamed as (select id as ticket_id, tenant_id from source)

select *
from renamed
