with source as (

    select * from {{ source('matching_results', 'match_date') }}

),

renamed as (

    select
        crm_account_id,
        match_date

    from source

)

select * from renamed