MODEL (
  name models.stg_customers,
  kind VIEW,
  description 'Customer data with basic cleaning and transformation applied, one row per customer.',
  audits (
    UNIQUE_VALUES(columns=(customer_id)),
    NOT_NULL(columns=(customer_id,customer_unique_id,customer_zip_code_prefix,customer_city,customer_state)),
  ),
  columns (
    customer_id TEXT COMMENT 'The unique key for each customer.',
    customer_unique_id TEXT COMMENT 'An identifier for each customer across multiple orders.',
    customer_zip_code_prefix INTEGER COMMENT 'The zip code prefix of the customer.',
    customer_city TEXT COMMENT 'The city of the customer.',
    customer_state TEXT COMMENT 'The state of the customer.'
  )
);

with source as (

    select * from raw.olist_customers_dataset

),

renamed as (

    select
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state

    from source

)

select * from renamed