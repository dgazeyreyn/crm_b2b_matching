with
    source as (select * from {{ source("customer_support", "feedback_themes") }}),

    renamed as (select id as ticket_id, feedback_theme from source)

select *
from renamed
