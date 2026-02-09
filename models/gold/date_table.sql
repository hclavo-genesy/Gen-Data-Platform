{{ config(materialized='table', schema='Gold')}}

with d as (
    select * from {{ source('silver', 'GW_HOLIDAY_POLICY')}}
),
gw_policy as (
    select * from {{ source('silver', 'GW_HOLIDAY_POLICY') }}
),
holidays as (
    select * from {{ source('silver', 'DIM_HOLIDAY') }}
)