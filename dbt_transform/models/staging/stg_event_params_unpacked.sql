{{
    config(
        materialized='table',
    )
}}

WITH CTE AS (
  SELECT
    e._dlt_id as event_id,
    e.event_date,
    e.event_timestamp,
    e.event_name,
    ep.key,
    COALESCE(CAST(ep.value__int_value AS STRING), ep.value__string_value) as value
  FROM  {{ source("ga4_select_star", "events") }} e
  JOIN  {{ source("ga4_select_star", "events__event_params") }} ep
  ON e._dlt_id = ep._dlt_parent_id
)

SELECT
    event_id,
    event_date,
    event_timestamp,
    event_name,
    {% for param in var('event_params') %}
        MAX(
            CASE
                WHEN key = '{{ param }}' THEN value
            END
        ) as {{ param }},
    {% endfor %}

FROM CTE
GROUP BY event_id, event_date, event_timestamp, event_name
ORDER BY event_date, event_timestamp