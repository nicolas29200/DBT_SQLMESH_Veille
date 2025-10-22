MODEL (
  name models.int_sellers_performance,
  kind VIEW
);

WITH sellers AS (
    SELECT * FROM models.stg_sellers
),
order_items AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id) AS nb_sales,
        SUM(price) AS total_revenue,
        SUM(freight_value) AS total_freight
    FROM models.stg_order_items
    GROUP BY 1
),
reviews AS (
    SELECT
        i.seller_id,
        AVG(r.review_score) AS avg_review_score
    FROM models.stg_order_items i
    LEFT JOIN models.stg_order_reviews r ON i.order_id = r.order_id
    GROUP BY 1
)
SELECT
    s.seller_id,
    s.seller_zip_code_prefix,
    s.seller_city,
    s.seller_state,
    COALESCE(o.nb_sales, 0) AS nb_sales,
    COALESCE(o.total_revenue, 0) AS total_revenue,
    COALESCE(o.total_freight, 0) AS total_freight,
    COALESCE(r.avg_review_score, 0) AS avg_review_score
FROM sellers s
LEFT JOIN order_items o ON s.seller_id = o.seller_id
LEFT JOIN reviews r ON s.seller_id = r.seller_id