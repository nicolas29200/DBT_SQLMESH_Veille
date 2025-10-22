MODEL (
  name models.stg_product_category_name_translation,
  kind VIEW
);

with source as (

    select * from raw.product_category_name_translation

),

renamed as (

    select
        product_category_name,
        product_category_name_english

    from source

)

select * from renamed