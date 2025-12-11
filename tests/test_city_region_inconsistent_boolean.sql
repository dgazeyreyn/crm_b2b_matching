SELECT *
FROM {{ ref('mart_company_quality') }}
WHERE city_region_inconsistent NOT IN (true, false)