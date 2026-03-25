{% macro refresh_holidays() %}

  {% set country_code = var('holiday_country_code', 'US') %}
  {% set start_date = var('start_date') %}
  {% set end_date = var('end_date') %}

  {% set start_year = start_date[0:4] %}
  {% set end_year = end_date[0:4] %}

  {% do run_query(
    "CALL ANALYTICS_DEV.SILVER.SP_REFRESH_HOLIDAYS('" 
    ~ country_code ~ "', " 
    ~ start_year ~ ", " 
    ~ end_year ~ ");"
  ) %}

{% endmacro %}