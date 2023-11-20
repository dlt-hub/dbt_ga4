{% macro get_filtered_columns(from, except=[]) %}

    {% set include_cols = [] %}
    {% set cols = adapter.get_columns_in_relation(from) %}
    {% set except = except | map("lower") | list %}
    {% for col in cols %}
        {% if col.column|lower not in except %}
            {% do include_cols.append(col.column) %}
        {% endif %}
    {% endfor %}

    {{ return(include_cols) }}

{% endmacro %}