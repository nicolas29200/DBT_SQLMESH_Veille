SELECT
    i.order_id,
    i.product_id,
    i.seller_id,
    p.product_category_name_english,
    i.price,
    i.freight_value,
    r.review_score,
    r.review_comment_message,
    r.review_creation_date
FROM {{ ref('stg_order_items') }} i
LEFT JOIN {{ ref('int_products_enriched') }} p ON i.product_id = p.product_id
LEFT JOIN {{ ref('stg_order_reviews') }} r ON i.order_id = r.order_id