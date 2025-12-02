with
    source as (select * from {{ source("crm_tenants", "segments") }}),

    renamed as (select tenant_id, customer_segment from source)

select *
from renamed
