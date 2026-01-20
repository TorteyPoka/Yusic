-- Cleanup Test Users
-- Run this in Supabase SQL Editor if you have test registrations that failed
-- https://app.supabase.com/project/vkrmpzjjwsmqcyakjeag/sql

-- 1. Check existing users
SELECT id, email, name, usertype FROM users;

-- 2. Delete test user(s) - replace with your test email
DELETE FROM auth.users WHERE email = 'shayon25@gmail.com';
DELETE FROM users WHERE email = 'shayon25@gmail.com';

-- 3. Verify tables have correct columns (lowercase)
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Expected columns (all lowercase):
-- id, email, name, usertype, bio, privatefoldercount, privatefolderlimit, profileimage, createdat, lastlogin
