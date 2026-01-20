# Fix Registration Issue - Email Confirmation

## Problem
Registration is failing because Supabase requires email confirmation by default. When a user signs up, they need to confirm their email before they can use the app.

## Solution Options

### Option 1: Disable Email Confirmation (Recommended for Development)

**This is the easiest fix for testing:**

1. Go to your Supabase dashboard: https://app.supabase.com/project/vkrmpzjjwsmqcyakjeag

2. Navigate to: **Authentication** → **Settings** → **Email Auth**

3. Find **"Enable email confirmations"** and **TURN IT OFF**

4. Scroll down and click **Save**

5. Try registering again - it should work immediately!

---

### Option 2: Keep Email Confirmation (Better for Production)

If you want to keep email confirmation enabled:

1. **Add Email Templates** (Optional but recommended):
   - Go to: **Authentication** → **Email Templates**
   - Customize the "Confirm signup" template

2. **Handle Email Confirmation in Your App**:
   - After registration, show a message telling users to check their email
   - Add a "Resend confirmation email" button
   - The user must click the link in their email before they can log in

3. **The app will now**:
   - Show a message after registration: "Please check your email to confirm your account"
   - Redirect user back to login screen
   - User clicks email confirmation link
   - User can then log in successfully

---

## Quick Test

After making your choice:

1. **Clear any failed registrations** (if needed):
   ```sql
   -- Run in Supabase SQL Editor if you have test accounts stuck
   -- Go to: https://app.supabase.com/project/vkrmpzjjwsmqcyakjeag/sql
   
   DELETE FROM auth.users WHERE email = 'your-test-email@example.com';
   DELETE FROM users WHERE email = 'your-test-email@example.com';
   ```

2. **Try registering** with a new email address

3. **Should work!** ✅

---

## Additional Checks

If registration still fails:

### 1. Check Email Provider Settings
- **Authentication** → **Settings** → **Email Auth**
- Make sure SMTP is configured OR use Supabase's default email service
- For development, Supabase's built-in email works fine

### 2. Check Auth Settings
- **Authentication** → **Settings**
- **Site URL**: Should be your app's URL (for localhost: `http://localhost`)
- **Redirect URLs**: Add your app URLs if needed

### 3. Check Database Tables
Make sure the `users` table exists with correct schema:
```sql
-- Verify table exists
SELECT * FROM users LIMIT 1;
```

### 4. Check RLS Policies
The "Anyone can insert users" policy should be enabled:
```sql
-- If needed, recreate the policy:
DROP POLICY IF EXISTS "Anyone can insert users" ON users;

CREATE POLICY "Anyone can insert users"
  ON users FOR INSERT
  WITH CHECK (true);
```

---

## Current Code Changes

I've updated your code to:
1. ✅ Add a 500ms delay before inserting into users table (gives Supabase time to fully create the auth user)
2. ✅ Detect if email confirmation is required and show appropriate message
3. ✅ Better error handling with more specific messages
4. ✅ Print full error to console for debugging
5. ✅ Handle duplicate email registrations
6. ✅ Handle foreign key constraint errors

---

## Testing

Try this test flow:

1. Go to your app
2. Click "Register"
3. Fill in details:
   - Name: `Test User`
   - Email: `test@example.com` (use a real email if email confirmation is ON)
   - Password: `test123`
   - User Type: Artist
4. Click "Register"
5. Watch the console/logs for any errors
6. Should either:
   - **Success**: Navigate to artist home screen
   - **Email Confirmation**: Show message about checking email
   - **Error**: Show specific error message

---

## Need More Help?

Check the Flutter console output - I've added detailed error logging:
```
Registration error: [full error details]
```

This will tell you exactly what's wrong!
