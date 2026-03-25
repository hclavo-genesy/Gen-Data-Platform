{{ config(
    materialized='view',
    schema='GOLD',
    alias='MONTHLY_AVAILABLE_HOURS'
) }}

SELECT
    DATE_TRUNC('month', month_start)::DATE AS month_start,
    LAST_DAY(month_end, 'month')::DATE AS month_end,
    COUNT_IF(is_weekday AND NOT is_holiday) AS available_workdays,
    COUNT_IF(is_weekday AND NOT is_holiday) * 4 AS available_work_hours
FROM {{ ref('date_table') }}
GROUP BY 1, 2
ORDER BY month_start