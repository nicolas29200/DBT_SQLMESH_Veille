MODEL (
  name models.stg_order_items,
  kind VIEW,
  description 'Order items data with basic cleaning and transformation applied, one row per order item.',
  audits (
    NOT_NULL(columns=(order_id,order_item_id,product_id,seller_id,shipping_limit_date,price,freight_value))
  )
);

with source as (

    select * from raw.olist_order_items_dataset

),

renamed as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp) as shipping_limit_date,
        price,
        freight_value

    from source

)

select * from renamed