with source as (

    select * from {{ source('olist', 'olist_order_reviews_dataset') }}

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