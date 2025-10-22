MODEL (
  name models.fct_product_metrics,
  kind FULL

);

SELECT
    p.PRODUCT_ID,
    p.PRODUCT_CATEGORY_NAME_ENGLISH AS category,
    p.NB_ORDERS AS total_sales,
    p.TOTAL_REVENUE AS total_revenue,
    p.AVG_PRICE,
    COUNT(DISTINCT s.seller_id) AS nb_sellers
FROM models.int_products_enriched p
LEFT JOIN models.stg_order_items oi ON p.PRODUCT_ID = oi.product_id
LEFT JOIN models.stg_sellers s ON oi.seller_id = s.seller_id
GROUP BY 1, 2, 3, 4, 5