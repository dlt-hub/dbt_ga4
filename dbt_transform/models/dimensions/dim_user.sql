WITH SessionData AS (
  SELECT
    e.user_pseudo_id,
    e.privacy_info__uses_transient_token,
    e.user_ltv__currency,
    ep.ga_session_id,
    ep.event_name,
    ep.page_title,
    ep.event_timestamp,
    MIN(ep.event_timestamp) OVER (PARTITION BY ep.ga_session_id) AS first_seen,
    MAX(ep.event_timestamp) OVER (PARTITION BY ep.ga_session_id) AS last_seen
  FROM
    {{ ref('stg_events') }} e
  JOIN
    {{ ref('stg_event_params_unpacked') }} ep
  ON
    e.event_id = ep.event_id
)

SELECT
  user_pseudo_id,
  privacy_info__uses_transient_token,
  user_ltv__currency,
  ga_session_id,
  COUNT(DISTINCT ga_session_id) AS nr_of_sessions,
  first_seen as frist_seen_timestamp,
  MAX(CASE WHEN event_timestamp = first_seen THEN event_name END) AS first_seen_event,
  MAX(CASE WHEN event_timestamp = first_seen THEN page_title END) AS first_seen_page,
  last_seen as last_seen_timestamp,
  MAX(CASE WHEN event_timestamp = last_seen THEN event_name END) AS last_seen_event,
  MAX(CASE WHEN event_timestamp = last_seen THEN page_title END) AS last_seen_page
FROM
  SessionData
GROUP BY
  user_pseudo_id,
  privacy_info__uses_transient_token,
  user_ltv__currency,
  ga_session_id,
  first_seen,
  last_seen