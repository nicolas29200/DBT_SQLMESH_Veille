MODEL (
  name models.stg_order_payments,
  kind VIEW
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