SELECT
    _dlt_parent_id as event_id,
    key as event_name,
    value__int_value as int_value,
    value__string_value as string_value

    -- if loaded by dlt, in this case is not loaded
    -- value__float_value as float_value,
    -- value__double_value as double_value
FROM
    {{ source("ga4_select_star", "events__event_params") }}