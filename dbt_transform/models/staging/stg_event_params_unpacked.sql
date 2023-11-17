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
  FROM  {{ source("ga4_select_star","events") }} e
  JOIN  {{ source("ga4_select_star","events__event_params") }} ep
  ON e._dlt_id = ep._dlt_parent_id
)

SELECT
  event_id,
  event_date,
  event_timestamp,
  event_name,
  MAX(CASE WHEN key = 'term' THEN value END) AS term,
  MAX(CASE WHEN key = 'medium' THEN value END) AS medium,
  MAX(CASE WHEN key = 'source' THEN value END) AS source,
  MAX(CASE WHEN key = 'campaign' THEN value END) AS campaign,
  MAX(CASE WHEN key = 'link_url' THEN value END) AS link_url,
  MAX(CASE WHEN key = 'outbound' THEN value END) AS outbound,
  MAX(CASE WHEN key = 'entrances' THEN value END) AS entrances,
  MAX(CASE WHEN key = 'page_path' THEN value END) AS page_path,
  MAX(CASE WHEN key = 'page_title' THEN value END) AS page_title,
  MAX(CASE WHEN key = 'link_domain' THEN value END) AS link_domain,
  MAX(CASE WHEN key = 'ga_session_id' THEN value END) AS ga_session_id,
  MAX(CASE WHEN key = 'page_location' THEN value END) AS page_location,
  MAX(CASE WHEN key = 'page_referrer' THEN value END) AS page_referrer,
  MAX(CASE WHEN key = 'first_field_id' THEN value END) AS first_field_id,
  MAX(CASE WHEN key = 'ignore_referrer' THEN value END) AS ignore_referrer,
  MAX(CASE WHEN key = 'session_engaged' THEN value END) AS session_engaged,
  MAX(CASE WHEN key = 'first_field_type' THEN value END) AS first_field_type,
  MAX(CASE WHEN key = 'form_destination' THEN value END) AS form_destination,
  MAX(CASE WHEN key = 'percent_scrolled' THEN value END) AS percent_scrolled,
  MAX(CASE WHEN key = 'ga_session_number' THEN value END) AS ga_session_number,
  MAX(CASE WHEN key = 'engagement_time_msec' THEN value END) AS engagement_time_msec,
  MAX(CASE WHEN key = 'first_field_position' THEN value END) AS first_field_position,
  MAX(CASE WHEN key = 'engaged_session_event' THEN value END) AS engaged_session_event,
  MAX(CASE WHEN key = 'form_length' THEN value END) AS form_length,
  MAX(CASE WHEN key = 'link_classes' THEN value END) AS link_classes
FROM CTE
GROUP BY event_id, event_date, event_timestamp, event_name
ORDER BY event_date, event_timestamp