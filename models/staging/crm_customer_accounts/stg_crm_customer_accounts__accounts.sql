with
    source as (select * from {{ source("crm_customer_accounts", "accounts") }}),

    renamed as (select crm_account_id, crm_account_name, tenant_id from source)

select *
from renamed
