WITH base AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS nb_orders,
    SUM(o.total_payments) AS total_revenue,
    AVG(o.total_payments) AS avg_order_value,
    MAX(o.order_purchase_timestamp) AS last_purchase_date
  FROM {{ ref('int_orders_enriched') }} o
  JOIN {{ ref('stg_customers') }} c ON o.customer_id = c.customer_id
  GROUP BY 1
)
SELECT *,
       DATE_PART('day', NOW() - last_purchase_date::timestamp) AS days_since_last_order
FROM base