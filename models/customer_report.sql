-- models/customer_report.sql
-- Builds a weekly customer summary used by the executive dashboard.

with base_users as (

    select
        id as user_id,
        email,
        created_at,
        country
    from {{ ref('users') }}

),

orders_agg as (

    select
        user_id,
        count(*) as total_orders,
        sum(amount) as lifetime_value
    from {{ ref('orders') }}
    group by user_id

)

select
    base_users.user_id,
    base_users.email,
    base_users.country,
    base_users.created_at,
    coalesce(orders_agg.total_orders, 0) as total_orders,
    coalesce(orders_agg.lifetime_value, 0) as lifetime_value
from base_users
left join orders_agg
    on base_users.user_id = orders_agg.user_id
