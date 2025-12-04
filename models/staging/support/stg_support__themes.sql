with source as (

    select * from {{ source('support', 'themes') }}

),

renamed as (

    select
        tenant_id,
        customer_segment,
        feedback_theme,
        frequency,
        avg_severity,
        ticket_date,
        resolution_days

    from source

)

select * from renamed