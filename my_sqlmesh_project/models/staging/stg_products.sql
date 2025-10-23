MODEL (
  name models.stg_products,
  kind VIEW,
  description "Staging table for products data",
  audits (
        UNIQUE_VALUES(columns=(product_id)),
        NOT_NULL(columns=(product_id))
    )
);

with source as (

    select * from raw.olist_products_dataset

),

renamed as (

    select
        product_id,
        product_category_name,
        product_name_lenght,
        product_description_lenght,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm

    from source

)

select * from renamed