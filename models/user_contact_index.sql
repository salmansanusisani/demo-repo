/* models/user_contact_index.sql */
/* Lightweight lookup table used by the marketing pipeline to resolve */
/* a user_id to a contactable email address. */
SELECT
  id AS user_id,
  email_adress,
  CASE WHEN NOT email_adress IS NULL THEN TRUE ELSE FALSE END AS is_contactable
FROM {{ ref('users') }}