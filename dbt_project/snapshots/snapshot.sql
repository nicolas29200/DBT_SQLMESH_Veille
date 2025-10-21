-- This file defines a snapshot of the data at a specific point in time, allowing for historical comparisons.

{% snapshot my_snapshot %}
    target_database: your_database_name
    target_schema: your_schema_name
    unique_key: your_unique_key_column

    select
        *
    from
        your_source_table
{% endsnapshot %}