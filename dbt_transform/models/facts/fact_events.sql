SELECT
    e.event_id,
    e.event_timestamp,
    e.event_bundle_sequence_id,
    e.user_first_touch_timestamp,
    e.user_ltv__revenue,
    e.user_pseudo_id,
    ep.medium,
    ep.source,
    ep.campaign,
    ep.term,
    ep.percent_scrolled,
    ep.engaged_session_event
FROM
    {{ ref("stg_events") }} e
JOIN
    {{ ref("stg_event_params_unpacked") }} ep
ON e.event_id = ep.event_id