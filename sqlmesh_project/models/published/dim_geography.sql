SELECT
    geolocation_zip_code_prefix AS zip_code,
    geolocation_city AS city,
    geolocation_state AS state,
    geolocation_lat AS latitude,
    geolocation_lng AS longitude,
    nb_customers,
    nb_sellers
FROM {{ ref('int_geolocation_enriched') }}
