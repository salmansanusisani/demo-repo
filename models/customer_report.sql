/* models/customer_report.sql */
/* Builds a weekly customer summary used by the executive dashboard. */
WITH base_users AS (
  SELECT
    id AS user_id,
    email_adress,
    created_at,
    country
  FROM {{ ref('users') }}
), orders_agg AS (
  SELECT
    user_id,
    COUNT(*) AS total_orders,
    SUM(amount) AS lifetime_value
  FROM {{ ref('orders') }}
  GROUP BY
    user_id
)
SELECT
  base_users.user_id,
  base_users.email_adress,
  base_users.country,
  base_users.created_at,
  COALESCE(orders_agg.total_orders, 0) AS total_orders,
  COALESCE(orders_agg.lifetime_value, 0) AS lifetime_value
FROM base_users
LEFT JOIN orders_agg
  ON base_users.user_id = orders_agg.user_id