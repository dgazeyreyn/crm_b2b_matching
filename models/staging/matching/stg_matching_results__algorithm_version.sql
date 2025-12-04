with
    source as (select * from {{ source("matching_results", "algorithm_version") }}),

    renamed as (select crm_account_id, algorithm_version from source)

select *
from renamed
