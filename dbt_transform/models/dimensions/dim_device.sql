SELECT
    {{ dbt.concat(["event_id", "'-'", "device__mobile_brand_name"]) }} as device_sk,
    event_id,
    device__category,
    device__mobile_brand_name,
    device__mobile_model_name,
    device__mobile_marketing_name,
    device__operating_system,
    device__operating_system_version,
    device__language,
    device__is_limited_ad_tracking,
    device__web_info__browser,
    device__web_info__browser_version,
    device__web_info__hostname
FROM {{ ref("stg_events") }}