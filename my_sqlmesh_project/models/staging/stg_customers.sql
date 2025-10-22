MODEL (
  name models.stg_customers,
  kind VIEW
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