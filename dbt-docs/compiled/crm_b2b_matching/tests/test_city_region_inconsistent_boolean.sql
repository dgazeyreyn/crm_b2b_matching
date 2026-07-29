SELECT *
FROM `zi-case-study`.`dbt_dreynolds`.`mart_company_quality`
WHERE city_region_inconsistent NOT IN (true, false)