{{ config(
    materialized='table',
    schema='GOLD',
    alias='DATE_TABLE'
) }}

{% set start_date = var('start_date') %}
{% set end_date = var('end_date') %}
{% set country_code = var('holiday_country_code') %}

WITH date_spine AS (
    SELECT DATEADD(day, seq4(), TO_DATE('{{ start_date }}')) AS dt
    FROM TABLE(GENERATOR(rowcount => 5000))
    WHERE DATEADD(day, seq4(), TO_DATE('{{ start_date }}')) <= TO_DATE('{{ end_date }}')
),

gw_holidays AS (
    SELECT
        h.date AS holiday_date,
        h.holiday_name
    FROM {{ source('analytics_dev_silver', 'dim_holiday') }} h
    JOIN {{ source('analytics_dev_silver', 'gw_holiday_policy') }} p
      ON p.country_code = h.country_code
     AND p.holiday_name = h.holiday_name
     AND p.is_gw_holiday = TRUE
    WHERE h.country_code = '{{ country_code }}'
)

SELECT
    ds.dt AS date,
    TO_VARCHAR(YEAR(ds.dt)) AS year,
    TO_VARCHAR(WEEKOFYEAR(ds.dt)) AS week_of_year,
    TO_VARCHAR(MONTH(ds.dt)) AS month_number,
    TO_VARCHAR(MONTH(ds.dt)) AS month_of_year,
    DATE_TRUNC('month', ds.dt)::DATE AS month_start,
    LAST_DAY(ds.dt)::DATE AS month_end,
    TO_CHAR(ds.dt, 'MMMM') AS month_name,
    TO_CHAR(ds.dt, 'MON') AS month_short,
    TO_VARCHAR(DAY(ds.dt)) AS month_day_number,
    TO_CHAR(ds.dt, 'DY') AS day_name,
    TO_CHAR(ds.dt, 'MMMM-YYYY') AS month_year,
    IFF(DAYOFWEEKISO(ds.dt) BETWEEN 1 AND 5, TRUE, FALSE) AS is_weekday,
    IFF(DAYOFWEEKISO(ds.dt) IN (6, 7), TRUE, FALSE) AS is_weekend,
    CASE
      WHEN MONTH(ds.dt) = 12 AND DAY(ds.dt) = 31 THEN FALSE
      ELSE IFF(gw.holiday_date IS NOT NULL, TRUE, FALSE)
    END AS is_holiday,
    CASE
      WHEN MONTH(ds.dt) = 12 AND DAY(ds.dt) = 31 THEN NULL
      ELSE gw.holiday_name
    END AS gw_holidays_names,
    (
      IFF(DAYOFWEEKISO(ds.dt) BETWEEN 1 AND 5, TRUE, FALSE)
      AND NOT (
        CASE
          WHEN MONTH(ds.dt) = 12 AND DAY(ds.dt) = 31 THEN FALSE
          ELSE IFF(gw.holiday_date IS NOT NULL, TRUE, FALSE)
        END
      )
    ) AS is_workday,
    IFF(
      MONTH(ds.dt) IN (7, 8),
      FALSE,
      (
        IFF(DAYOFWEEKISO(ds.dt) BETWEEN 1 AND 5, TRUE, FALSE)
        AND NOT (
          CASE
            WHEN MONTH(ds.dt) = 12 AND DAY(ds.dt) = 31 THEN FALSE
            ELSE IFF(gw.holiday_date IS NOT NULL, TRUE, FALSE)
          END
        )
      )
    ) AS is_internship_month
FROM date_spine ds
LEFT JOIN gw_holidays gw
  ON ds.dt = gw.holiday_date
ORDER BY date