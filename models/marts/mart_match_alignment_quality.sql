{{ config(materialized="table") }}

select
    m.crm_account_id,
    m.zi_company_id,

    a.tenant_id,

    a.crm_account_region as crm_region,
    c.zi_company_region as company_region,

    case
        when a.crm_account_region = c.zi_company_region then false else true
    end as region_mismatch,

    current_timestamp() as loaded_at

from {{ ref("fact_match") }} m
join {{ ref("dim_crm_account") }} a on m.crm_account_id = a.crm_account_id
join {{ ref("dim_company") }} c on m.zi_company_id = c.zi_company_id
