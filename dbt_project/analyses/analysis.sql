-- This file contains SQL queries for analysis purposes.
-- You can add your analysis queries below.

SELECT *
FROM {{ ref('your_model_name') }}
WHERE condition = 'value';