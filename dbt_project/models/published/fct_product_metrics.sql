SELECT
    p.product_id,
    p.product_category_name_english AS category,
    p.nb_orders AS total_sales,
    p.total_revenue,
    p.avg_price,
    COUNT(DISTINCT s.seller_id) AS nb_sellers
FROM {{ ref('int_products_enriched') }} p
LEFT JOIN {{ ref('stg_order_items') }} oi ON p.product_id = oi.product_id
LEFT JOIN {{ ref('stg_sellers') }} s ON oi.seller_id = s.seller_id
GROUP BY 1, 2, 3, 4, 5