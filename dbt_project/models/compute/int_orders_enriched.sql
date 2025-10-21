WITH orders AS (
  SELECT * FROM {{ ref('stg_orders') }}
),
items AS (
  SELECT order_id,
         SUM(price) AS total_price,
         SUM(freight_value) AS total_freight,
         COUNT(*) AS nb_items
  FROM {{ ref('stg_order_items') }}
  GROUP BY 1
),
payments AS (
  SELECT order_id,
         SUM(payment_value) AS total_payment,
         MAX(payment_installments) AS max_installments
  FROM {{ ref('stg_order_payments') }}
  GROUP BY 1
),
reviews AS (
  SELECT order_id,
         AVG(review_score) AS avg_review_score
  FROM {{ ref('stg_order_reviews') }}
  GROUP BY 1
)
SELECT
  o.order_id,
  o.customer_id,
  o.order_status,
  o.order_purchase_timestamp,
  i.total_price,
  i.total_freight,
  p.total_payment,
  p.max_installments,
  r.avg_review_score
FROM orders o
LEFT JOIN items i ON o.order_id = i.order_id
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id