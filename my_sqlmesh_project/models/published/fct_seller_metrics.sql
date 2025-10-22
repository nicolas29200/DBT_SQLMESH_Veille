MODEL (
  name models.fct_seller_metrics,
  kind FULL

);

SELECT
    SELLER_ID,
    SELLER_ZIP_CODE_PREFIX,
    SELLER_CITY,
    SELLER_STATE,
    NB_SALES,
    TOTAL_REVENUE,
    TOTAL_FREIGHT,
    AVG_REVIEW_SCORE,
    ROUND(TOTAL_REVENUE::numeric / NULLIF(NB_SALES::numeric, 0), 2) AS avg_order_value
FROM models.int_sellers_performance 
where NB_SALES>0