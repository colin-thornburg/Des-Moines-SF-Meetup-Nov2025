{{
  config(
    materialized='dynamic_table',
    snowflake_warehouse='transforming',
    target_lag='downstream',
    on_configuration_change='apply',
    post_hook=[
      "ALTER DYNAMIC TABLE {{ this }} REFRESH"
    ]
  )
}}

WITH source_interactions AS (
    SELECT
        interaction_id,
        customer_id,
        interaction_timestamp,
        interaction_type,
        interaction_value_usd,
        channel,
        session_id,
        _metadata_loaded_at
    FROM {{ ref('stg_customer_interactions') }}
    WHERE interaction_timestamp IS NOT NULL
      AND interaction_id IS NOT NULL
),

validated_interactions AS (
    SELECT 
        *
    FROM source_interactions
    WHERE interaction_type IN ('purchase', 'support_ticket', 'web_visit', 'app_open', 'call_center')
      AND customer_id IS NOT NULL
)

SELECT 
    interaction_id,
    customer_id,
    interaction_timestamp,
    interaction_type,
    interaction_value_usd,
    channel,
    session_id,
    _metadata_loaded_at
FROM validated_interactions