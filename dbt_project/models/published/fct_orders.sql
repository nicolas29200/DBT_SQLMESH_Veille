SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    total_price,
    total_freight,
    total_payment,
    max_installments,
    avg_review_score
FROM {{ ref('int_orders_enriched') }}

