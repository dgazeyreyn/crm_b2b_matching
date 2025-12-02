with tickets as (

    select * from {{ ref('stg_customer_support__tickets') }}
),

segments as (

    select * from {{ ref('stg_crm_tenants__segments') }}
),

themes as (

    select * from {{ ref('stg_customer_support__feedback_themes') }}
),

frequency as (

    select * from {{ ref('stg_customer_support__frequency') }}
),

severity as (

    select * from {{ ref('stg_customer_support__severity') }}
),

dates as (

    select * from {{ ref('stg_customer_support__ticket_dates') }}
),

res_days as (

    select * from {{ ref('stg_customer_support__resolution_days') }}
),

final as (

select
    tickets.tenant_id,
    segments.customer_segment,
    themes.feedback_theme,
    frequency.frequency,
    severity.avg_severity,
    dates.ticket_date,
    res_days.resolution_days
from tickets
join segments on segments.tenant_id = tickets.tenant_id
join themes on themes.ticket_id = tickets.ticket_id
join frequency on frequency.ticket_id = tickets.ticket_id
join severity on severity.ticket_id = tickets.ticket_id
join dates on dates.ticket_id = tickets.ticket_id
join res_days on res_days.ticket_id = tickets.ticket_id

)

select
    {{ dbt_utils.generate_surrogate_key(['tenant_id', 'ticket_date']) }} as primary_key,
    *  
from
    final