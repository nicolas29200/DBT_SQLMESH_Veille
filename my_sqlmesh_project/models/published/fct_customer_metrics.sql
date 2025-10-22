MODEL (
  name models.fct_customer_metrics,
  kind FULL

);

WITH base AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.ORDER_ID) AS nb_orders,
    SUM(o.TOTAL_PAYMENT) AS total_revenue,
    AVG(o.TOTAL_PAYMENT) AS avg_order_value,
    MAX(o.ORDER_PURCHASE_TIMESTAMP) AS last_purchase_date
  FROM models.int_orders_enriched o
  JOIN models.stg_customers c ON o.CUSTOMER_ID = c.customer_id
  GROUP BY 1
)
SELECT *,
       DATE_PART('day', NOW() - last_purchase_date::timestamp) AS days_since_last_order
FROM base