SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    nb_sales,
    total_revenue,
    total_freight,
    avg_review_score,
    ROUND(total_revenue::numeric / NULLIF(nb_sales::numeric, 0), 2) AS avg_order_value
FROM {{ ref('int_sellers_performance') }} 
where nb_sales>0