MODEL (
  name models.stg_order_reviews,
  kind VIEW,
  description 'Order reviews data with basic cleaning and transformation applied, one row per order review.',
    audits (
        NOT_NULL(columns=(review_id,order_id,review_score,review_creation_date))
    )
);

with source as (

    select * from raw.olist_order_reviews_dataset

),

renamed as (

    select
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        cast(review_creation_date as date) as review_creation_date,
        cast(review_answer_timestamp as timestamp) as review_answer_timestamp

    from source

)

select * from renamed