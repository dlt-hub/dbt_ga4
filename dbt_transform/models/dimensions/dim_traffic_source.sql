{{
    config(
        materialized='table',
    )
}}

SELECT
    CONCAT(event_id, '-' , traffic_source__name) as traffic_sk,
    event_id,
    traffic_source__name,
    traffic_source__medium,
    traffic_source__source
    -- "Alena, create a macro that allows users to specify their paid sources. For instance, if Reddit ads are marked as organic by Google, the user can define them as paid, and the macro will adjust the custom_source field accordingly."
    -- case when traffic_source = "X" then 'paid' else 'organic' as custom_source
FROM
{{ ref("stg_events") }}