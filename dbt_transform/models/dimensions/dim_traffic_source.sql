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
    traffic_source__source,
    CASE
        WHEN traffic_source__name IN ({{ "'" + var('paid_sources')|join("', '") + "'" }}) THEN 'paid'
        ELSE 'organic'
    END as custom_source
FROM
    {{ ref("stg_events") }}
