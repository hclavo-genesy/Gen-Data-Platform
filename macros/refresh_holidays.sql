{% macro refresh_holidays(country_code='US') %}
  {% do run_query(
    "CALL ANALYTICS_DEV.SILVER.SP_REFRESH_HOLIDAYS('" ~ country_code ~ "');"
  ) %}
{% endmacro %}
