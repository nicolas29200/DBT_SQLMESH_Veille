MODEL (
  name models.stg_orders,
  kind VIEW,
  description "Staging table for orders data",
  audits (
        UNIQUE_VALUES(columns=(order_id,customer_id)),
        NOT_NULL(columns=(order_id,customer_id,order_status,order_purchase_timestamp,order_estimated_delivery_date))
    )
);

with source as (

    select * from raw.olist_orders_dataset

),

renamed as (

    select
        order_id,
        customer_id,
        order_status,
        cast(order_purchase_timestamp as timestamp) as order_purchase_timestamp,
        cast(order_approved_at as timestamp) as order_approved_at,
        cast(order_delivered_carrier_date as timestamp) as order_delivered_carrier_date,
        cast(order_delivered_customer_date as timestamp) as order_delivered_customer_date,
        cast(order_estimated_delivery_date as timestamp) as order_estimated_delivery_date

    from source

)

select * from renamed