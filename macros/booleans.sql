{% macro boolean_value(condition) -%}
    {{ return(adapter.dispatch('boolean_value')(condition)) }}
{%- endmacro %}

{% macro default__boolean_value(condition) -%}
    coalesce({{ condition }}, false)
{%- endmacro %}

{% macro sqlserver__boolean_value(condition) -%}
    cast(case when {{ condition }} then 1 else 0 end as bit)
{%- endmacro %}

{% macro boolean_is_true(expression) -%}
    {{ return(adapter.dispatch('boolean_is_true')(expression)) }}
{%- endmacro %}

{% macro default__boolean_is_true(expression) -%}
    {{ expression }}
{%- endmacro %}

{% macro sqlserver__boolean_is_true(expression) -%}
    {{ expression }} = cast(1 as bit)
{%- endmacro %}
