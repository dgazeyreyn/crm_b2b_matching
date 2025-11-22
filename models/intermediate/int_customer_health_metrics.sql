with tenants as (

    select * from {{ ref('stg_crm_tenants__tenants') }}
),

segments as (

    select * from {{ ref('stg_crm_tenants__segments') }}
),

acv as (

    select * from {{ ref('stg_crm_tenants__annual_contract_value') }}
),

nps as (

    select * from {{ ref('stg_crm_tenants__data_quality_nps') }}
),

industry as (

    select * from {{ ref('stg_crm_tenants__industries') }}
),

final as (

select
    tenants.*,
    segments.customer_segment,
    acv.annual_contract_value,
    nps.data_quality_nps,
    industry.industry
from tenants
join segments on segments.tenant_id = tenants.tenant_id
join acv on acv.tenant_id = tenants.tenant_id
join nps on nps.tenant_id = tenants.tenant_id
join industry on industry.tenant_id = tenants.tenant_id

)

select * from final