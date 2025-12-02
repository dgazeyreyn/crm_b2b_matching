with
    source as (

        select * from {{ source("internal_research", "manual_validation_sample") }}

    ),

    renamed as (

        select
            crm_account_id,
            zi_company_id,
            match_confidence_score,
            manual_validation_result,
            validation_notes,
            validator_name,
            validation_date

        from source

    )

select *
from renamed
