{% macro debug_context() %}
  {% set query %}
    SELECT
      CURRENT_ROLE()   AS role_name,
      CURRENT_USER()   AS user_name,
      CURRENT_DATABASE() AS db_name,
      CURRENT_SCHEMA() AS schema_name
  {% endset %}

  {% set results = run_query(query) %}

  {% if execute %}
    {% set role_name = results.columns[0].values()[0] %}
    {% set user_name = results.columns[1].values()[0] %}
    {% set db_name = results.columns[2].values()[0] %}
    {% set schema_name = results.columns[3].values()[0] %}

    {{ log("DBT ROLE: " ~ role_name, info=True) }}
    {{ log("DBT USER: " ~ user_name, info=True) }}
    {{ log("DBT DATABASE: " ~ db_name, info=True) }}
    {{ log("DBT SCHEMA: " ~ schema_name, info=True) }}
  {% endif %}
{% endmacro %}