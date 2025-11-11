{{
  config(
    materialized='view'
  )
}}

WITH source_interactions AS (
    SELECT
        value:interaction_id::varchar AS interaction_id,
        value:customer_id::varchar AS customer_id,
        value:timestamp::timestamp_ntz AS interaction_timestamp,
        value:type::varchar AS interaction_type,
        value:value_usd::number(18,2) AS interaction_value_usd,
        value:channel::varchar AS channel,
        value:session_id::varchar AS session_id,
        _metadata_loaded_at
    FROM {{ source('raw_desmoines_sf_meetup', 'customer_interactions') }}
)

SELECT * FROM source_interactions