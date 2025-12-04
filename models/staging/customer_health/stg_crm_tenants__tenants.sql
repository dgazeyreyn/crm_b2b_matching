with
    source as (select * from {{ source("crm_tenants", "tenants") }}),

    renamed as (select tenant_id, tenant_company_name from source)

select *
from renamed
