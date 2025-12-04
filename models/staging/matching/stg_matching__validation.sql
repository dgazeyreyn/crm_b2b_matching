with
    source as (select * from {{ source("matching", "validation") }}),

    renamed as (select crm_account_id, algorithm_version from source)

select *
from renamed
