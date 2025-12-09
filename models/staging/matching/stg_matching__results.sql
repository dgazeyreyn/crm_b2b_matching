with source as (

    select * from {{ source('matching', 'results') }}

),

renamed as (

    select
        crm_account_id,
        zi_company_id,
        match_confidence_score,
        match_date,
        algorithm_version

    from source

)

select * from renamed