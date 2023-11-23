SELECT
    _dlt_id as event_id
    {% for col in get_filtered_columns(from=source("ga4_select_star", "events"), except=["_dlt_id"])  %}
    , {{ col }} as {{ col }}
    {% endfor %}
FROM
    {{ source("ga4_select_star", "events") }}