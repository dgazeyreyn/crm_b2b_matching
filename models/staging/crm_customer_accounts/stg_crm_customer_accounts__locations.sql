with
    source as (select * from {{ source("crm_customer_accounts", "locations") }}),

    renamed as (

        select crm_account_id, crm_account_country, crm_account_region from source

    )

select *
from renamed
