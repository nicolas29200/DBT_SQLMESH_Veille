MODEL (
  name models.stg_geolocation,
  kind VIEW,
  description 'Geolocation data with basic cleaning and transformation applied, one row per geolocation entry.',
  audits (
    NOT_NULL(columns=(geolocation_zip_code_prefix,geolocation_lat,geolocation_lng,geolocation_city,geolocation_state)),
  )
);

with source as (

    select * from raw.olist_geolocation_dataset

),

renamed as (

    select
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state

    from source

)

select * from renamed