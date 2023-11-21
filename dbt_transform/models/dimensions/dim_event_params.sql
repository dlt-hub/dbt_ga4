SELECT
    event_id,
    event_name,
    int_value,
    string_value
    -- values if present
    -- float_value,
    -- decimal_value

FROM {{ ref("stg_event_params_original") }}