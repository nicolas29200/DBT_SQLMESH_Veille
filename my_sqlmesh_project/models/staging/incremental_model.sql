MODEL (
    name ibis.incremental_model,
    kind INCREMENTAL_BY_TIME_RANGE (
        time_column event_date,
        lookback 2 ,
    ),
    start '2020-01-01',
    grain (id, event_date)
);

SELECT
    id::int as id,
    item_id::int as item_id,
    event_date::date as event_date
FROM
    ibis.seed_model
WHERE
    event_date BETWEEN @start_date AND @end_date