{% macro refresh_holidays(country_code='US') %}
    {% set sql%}
        CALL ANALYTICS_DEV.SILVER.SP_REFRESH_HOLIDAYS(' {{country_code}}');
    {% endset %%}

    {{ log ("Running: " ~ sql, info=True) }}

    {% set res = run_query(sql) %}

    {{ log"Result: " ~ (res | string), info=True  }}

{% endmacro %}