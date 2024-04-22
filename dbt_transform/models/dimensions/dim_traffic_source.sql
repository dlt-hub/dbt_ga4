SELECT
    {{ dbt.concat(["event_id", "'-'" , "traffic_source__name"]) }} as traffic_sk,
    event_id,
    traffic_source__name,
    traffic_source__medium,
    traffic_source__source,
    CASE
        WHEN traffic_source__source IN ({{ "'" + var('ga4_data_paid_sources')|join("', '") + "'" }}) THEN 'paid'
        ELSE 'organic'
    END as custom_source
FROM
    {{ ref("stg_events") }}
