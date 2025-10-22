MODEL (
  name models.stg_sellers,
  kind VIEW
);

with source as (

    select * from raw.olist_sellers_dataset

),

renamed as (

    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state

    from source

)

select * from renamed