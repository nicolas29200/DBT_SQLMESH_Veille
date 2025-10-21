WITH geo AS (
    SELECT * FROM {{ ref('stg_geolocation') }}
),
customers AS (
    SELECT DISTINCT customer_zip_code_prefix
    FROM {{ ref('stg_customers') }}
),
sellers AS (
    SELECT DISTINCT seller_zip_code_prefix
    FROM {{ ref('stg_sellers') }}
),
geo_stats AS (
    SELECT
        g.geolocation_zip_code_prefix,
        g.geolocation_lat,
        g.geolocation_lng,
        g.geolocation_city,
        g.geolocation_state,
        COUNT(DISTINCT c.customer_zip_code_prefix) AS nb_customers,
        COUNT(DISTINCT s.seller_zip_code_prefix) AS nb_sellers
    FROM geo g
    LEFT JOIN customers c ON g.geolocation_zip_code_prefix = c.customer_zip_code_prefix
    LEFT JOIN sellers s ON g.geolocation_zip_code_prefix = s.seller_zip_code_prefix
    GROUP BY 1, 2, 3, 4, 5
)
SELECT *
FROM geo_stats