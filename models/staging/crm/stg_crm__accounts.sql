with
    source as (select * from {{ source("crm", "accounts") }}),

    renamed as (select crm_account_id, crm_account_name, tenant_id from source)

select *
from renamed
