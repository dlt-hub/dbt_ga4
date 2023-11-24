WITH CTE AS (
  SELECT
    e.event_id,
    e.event_date,
    e.event_timestamp,
    ep.event_name,
    COALESCE(CAST(ep.int_value AS {{ dbt.type_string() }}), ep.string_value) as param_value
  FROM  {{ ref("stg_events") }} e
  JOIN  {{ ref("stg_event_params_original") }} ep
  ON e.event_id = ep.event_id
)

SELECT
    event_id,
    event_date,
    event_timestamp,
    event_name
    {% for param in var('event_params') %}
    , MAX(
        CASE
            WHEN event_name = '{{ param }}' THEN param_value
        END
    ) as {{ param }}
    {% endfor %}
FROM CTE
GROUP BY event_id, event_date, event_timestamp, event_name
