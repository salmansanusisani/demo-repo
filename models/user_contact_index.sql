-- models/user_contact_index.sql
-- Lightweight lookup table used by the marketing pipeline to resolve
-- a user_id to a contactable email address.

select
    id as user_id,
    email,
    case
        when email is not null then true
        else false
    end as is_contactable
from {{ ref('users') }}
