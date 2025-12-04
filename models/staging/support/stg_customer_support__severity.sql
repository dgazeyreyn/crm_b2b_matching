with
    source as (select * from {{ source("customer_support", "severity") }}),

    renamed as (select id as ticket_id, avg_severity from source)

select *
from renamed
