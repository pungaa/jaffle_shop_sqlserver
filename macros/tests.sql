{% macro sqlserver__test_expression_is_true(model, expression, column_name) %}

{% if should_store_failures() %}
    {% set column_list = '*' %}
{% else %}
    {% set column_list = '1 as test_failure' %}
{% endif %}

select
    {{ column_list }}
from {{ model }}
{% if column_name is none %}
where not({{ expression }})
{%- else %}
where not({{ column_name }} {{ expression }})
{%- endif %}

{% endmacro %}
