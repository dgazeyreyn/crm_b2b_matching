with source as (

    select * from {{ source('matching_results', 'match_confidence_score') }}

),

renamed as (

    select
        crm_account_id,
        match_confidence_score

    from source

)

select * from renamed