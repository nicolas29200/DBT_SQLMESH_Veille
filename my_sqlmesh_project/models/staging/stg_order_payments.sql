MODEL (
  name models.stg_order_payments,
  kind VIEW,
  description 'Order payments data with basic cleaning and transformation applied, one row per order payment.',
    audits (
        NOT_NULL(columns=(order_id,payment_sequential,payment_type,payment_installments,payment_value))
    )
);

with source as (

    select * from raw.olist_order_payments_dataset

),

renamed as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value

    from source

)

select * from renamed