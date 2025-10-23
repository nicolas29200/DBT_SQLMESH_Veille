MODEL (
  name models.stg_sellers,
  kind VIEW,
  description "Staging table for sellers data",
  audits (
        UNIQUE_VALUES(columns=(seller_id)),
        NOT_NULL(columns=(seller_id,seller_zip_code_prefix,seller_city,seller_state))
    )
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