MODEL (
  name models.stg_product_category_name_translation,
  kind VIEW,
  description "Staging table for product category name translation data",
  audits (
        NOT_NULL(columns=(product_category_name, product_category_name_english))
    )
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