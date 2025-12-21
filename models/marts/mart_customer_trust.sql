select
    tenant_id,
    data_quality_nps,

    case
        when data_quality_nps between 0 and 6
        then 'detractor'
        when data_quality_nps in (7, 8)
        then 'passive'
        when data_quality_nps in (9, 10)
        then 'promoter'
    end as nps_category,

    data_quality_nps between 9 and 10 as is_promoter,
    data_quality_nps between 0 and 6 as is_detractor

from {{ ref("fact_customer_health") }}