MODEL (
  name models.fct_orders,
  kind FULL

);

SELECT
    ORDER_ID,
    CUSTOMER_ID,
    ORDER_STATUS,
    ORDER_PURCHASE_TIMESTAMP,
    TOTAL_PRICE,
    TOTAL_FREIGHT,
    TOTAL_PAYMENT,
    MAX_INSTALLMENTS,
    AVG_REVIEW_SCORE
FROM models.int_orders_enriched