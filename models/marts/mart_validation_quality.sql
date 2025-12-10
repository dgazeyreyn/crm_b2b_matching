-- models/marts/mart_validation_quality.sql
{{ config(materialized='table') }}

with validations as (
  select *
  from {{ ref('fact_manual_validation') }}
),

crm as (
  select crm_account_id, tenant_id
  from {{ ref('dim_crm_account') }}
),

per_crm as (
  select
    v.crm_account_id,
    coalesce(c.tenant_id, null) as tenant_id,
    count(*) as validation_count,
    sum(case when lower(v.manual_validation_result) in ('incorrect') then 1 else 0 end) as validation_incorrect_count,
    safe_divide(sum(case when lower(v.manual_validation_result) in ('incorrect') then 1 else 0 end), nullif(count(*),0)) as validation_incorrect_rate,
    min(validation_date) as first_validation_date,
    max(validation_date) as last_validation_date
  from validations v
  left join crm c
    on v.crm_account_id = c.crm_account_id
  group by 1,2
)

select
  {{ dbt_utils.generate_surrogate_key(['crm_account_id']) }} as validation_quality_id,
  crm_account_id,
  tenant_id,
  validation_count,
  validation_incorrect_count,
  validation_incorrect_rate,
  first_validation_date,
  last_validation_date
from per_crm