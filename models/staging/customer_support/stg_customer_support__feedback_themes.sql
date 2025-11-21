with source as (

    select * from {{ source('customer_support', 'feedback_themes') }}

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