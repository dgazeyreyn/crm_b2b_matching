with
    source as (select * from {{ source("crm_tenants", "data_quality_nps") }}),

    renamed as (select tenant_id, data_quality_nps from source)

select *
from renamed
