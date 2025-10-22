-- Test case to validate the staging model
WITH staging_data AS (
    SELECT * FROM {{ ref('staging_model') }}
)

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT id) AS unique_ids
FROM staging_data
WHERE id IS NOT NULL;

-- Test case to check for null values in important fields
WITH intermediate_data AS (
    SELECT * FROM {{ ref('intermediate_model') }}
)

SELECT
    COUNT(*) AS total_nulls
FROM intermediate_data
WHERE important_field IS NULL;

-- Test case to ensure data consistency between models
WITH marts_data AS (
    SELECT * FROM {{ ref('marts_model') }}
),
intermediate_data AS (
    SELECT * FROM {{ ref('intermediate_model') }}
)

SELECT
    COUNT(*) AS inconsistent_records
FROM marts_data m
LEFT JOIN intermediate_data i ON m.id = i.id
WHERE i.id IS NULL;