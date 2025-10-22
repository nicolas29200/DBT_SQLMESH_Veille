MODEL (
  name models.int_products_enriched,
  kind VIEW
);

WITH products AS (
    SELECT * FROM models.stg_products
),
categories AS (
    SELECT
        product_category_name,
        product_category_name_english
    FROM models.stg_product_category_name_translation
),
order_items AS (
    SELECT
        product_id,
        COUNT(DISTINCT order_id) AS nb_orders,
        SUM(price) AS total_revenue,
        AVG(price) AS avg_price
    FROM models.stg_order_items
    GROUP BY 1
)
SELECT
    p.product_id as product_id,
    p.product_category_name as product_category_name,
    c.product_category_name_english as product_category_name_english,
    p.product_name_lenght as product_name_lenght,
    p.product_description_lenght as product_description_lenght,
    p.product_photos_qty as product_photos_qty,
    COALESCE(o.nb_orders, 0) AS nb_orders,
    COALESCE(o.total_revenue, 0) AS total_revenue,
    COALESCE(o.avg_price, 0) AS avg_price
FROM products p
LEFT JOIN categories c ON p.product_category_name = c.product_category_name
LEFT JOIN order_items o ON p.product_id = o.product_id