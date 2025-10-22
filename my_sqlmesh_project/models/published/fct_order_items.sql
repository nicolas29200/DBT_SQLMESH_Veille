MODEL (
  name models.fct_order_items,
  kind FULL

);

WITH product_enriched AS (
  SELECT * FROM models.int_products_enriched
)
SELECT
    i.order_id,
    i.product_id,
    i.seller_id,
    p.PRODUCT_CATEGORY_NAME_ENGLISH,
    i.price,
    i.freight_value,
    r.review_score,
    r.review_comment_message,
    r.review_creation_date
FROM models.stg_order_items i
LEFT JOIN product_enriched p ON i.product_id = p.PRODUCT_ID
LEFT JOIN models.stg_order_reviews r ON i.order_id = r.order_id