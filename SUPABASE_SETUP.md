# Supabase Setup Guide for Yusic

This project uses Supabase as the backend. Follow these steps to set up your Supabase project.

## Prerequisites

- A Supabase account (sign up at https://supabase.com)

## Setup Steps

### 1. Create a Supabase Project

1. Go to https://app.supabase.com
2. Click "New Project"
3. Fill in your project details:
   - Project name: `yusic` (or your preferred name)
   - Database password: (create a strong password)
   - Region: Choose the closest region to your users

### 2. Get Your Project Credentials

1. Go to Project Settings > API
2. Copy your:
   - **Project URL** (e.g., `https://vkrmpzjjwsmqcyakjeag.supabase.co`)
   - **Anon/Public Key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrcm1wempqd3NtcWN5YWtqZWFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4ODYzNDYsImV4cCI6MjA4NDQ2MjM0Nn0.iY2mbOgM7qhnWiHuPd73A3Arny69LiOODoepFMyyhkI`)

### 3. Configure Your Flutter App

Open `lib/config/supabase_config.dart` and replace:
```dart
static const String supabaseUrl = 'https://vkrmpzjjwsmqcyakjeag.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrcm1wempqd3NtcWN5YWtqZWFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4ODYzNDYsImV4cCI6MjA4NDQ2MjM0Nn0.iY2mbOgM7qhnWiHuPd73A3Arny69LiOODoepFMyyhkI';
```

With your actual credentials from step 2.

### 4. Create Database Tables

Go to the SQL Editor in your Supabase dashboard and run these SQL commands:

#### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  userType TEXT NOT NULL CHECK (userType IN ('artist', 'studio')),
  bio TEXT DEFAULT '',
  privateFolderCount INTEGER DEFAULT 0,
  privateFolderLimit INTEGER DEFAULT 0,
  profileImage TEXT,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  lastLogin TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own data
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Anyone can insert (for registration)
CREATE POLICY "Anyone can insert users"
  ON users FOR INSERT
  WITH CHECK (true);
```

#### Folders Table
```sql
CREATE TABLE folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artistId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  isPublic BOOLEAN DEFAULT false,
  trackCount INTEGER DEFAULT 0,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE folders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own folders"
  ON folders FOR SELECT
  USING (auth.uid() = artistId OR isPublic = true);

CREATE POLICY "Users can insert own folders"
  ON folders FOR INSERT
  WITH CHECK (auth.uid() = artistId);

CREATE POLICY "Users can update own folders"
  ON folders FOR UPDATE
  USING (auth.uid() = artistId);

CREATE POLICY "Users can delete own folders"
  ON folders FOR DELETE
  USING (auth.uid() = artistId);
```

#### Tracks Table
```sql
CREATE TABLE tracks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  userId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  folderId UUID REFERENCES folders(id) ON DELETE CASCADE,
  trackName TEXT NOT NULL,
  trackUrl TEXT NOT NULL,
  genre TEXT DEFAULT '',
  artist TEXT DEFAULT '',
  duration INTEGER DEFAULT 0,
  albumArt TEXT DEFAULT '',
  fileSize BIGINT DEFAULT 0,
  plays INTEGER DEFAULT 0,
  likes INTEGER DEFAULT 0,
  uploadedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own tracks"
  ON tracks FOR SELECT
  USING (auth.uid() = userId);

CREATE POLICY "Users can insert own tracks"
  ON tracks FOR INSERT
  WITH CHECK (auth.uid() = userId);

CREATE POLICY "Users can update own tracks"
  ON tracks FOR UPDATE
  USING (auth.uid() = userId);

CREATE POLICY "Users can delete own tracks"
  ON tracks FOR DELETE
  USING (auth.uid() = userId);
```

#### Bookings Table
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  studioId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  artistId UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sessionType TEXT NOT NULL CHECK (sessionType IN ('recording', 'jamming')),
  startTime TIMESTAMP WITH TIME ZONE NOT NULL,
  endTime TIMESTAMP WITH TIME ZONE NOT NULL,
  totalAmount DECIMAL(10, 2) NOT NULL,
  paidAmount DECIMAL(10, 2) DEFAULT 0,
  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  notes TEXT DEFAULT '',
  paymentMethod TEXT,
  transactionId TEXT,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own bookings"
  ON bookings FOR SELECT
  USING (auth.uid() = studioId OR auth.uid() = artistId);

CREATE POLICY "Artists can create bookings"
  ON bookings FOR INSERT
  WITH CHECK (auth.uid() = artistId);

CREATE POLICY "Studios and artists can update bookings"
  ON bookings FOR UPDATE
  USING (auth.uid() = studioId OR auth.uid() = artistId);
```

### 5. Create Storage Buckets

1. Go to Storage in your Supabase dashboard
2. Create a bucket named `music-tracks`
3. Set the bucket to **Public** or configure appropriate policies
4. Create another bucket named `profile-images` (optional)

### 6. Test Your Connection

Run your Flutter app:
```bash
flutter run
```

The app should now connect to Supabase!

## Troubleshooting

- **Authentication Error**: Check that your Supabase URL and Anon Key are correct
- **Database Error**: Make sure all tables and policies are created
- **Storage Error**: Verify that storage buckets exist and have proper permissions

## Security Notes

- Never commit your `.env` file or credentials to version control
- The anon key is safe to use in client apps (it has limited permissions)
- Always use Row Level Security (RLS) policies to protect your data
- For production, consider using environment variables or secure key management

## Next Steps

- Customize the database schema for your needs
- Add more tables/features as needed
- Set up Supabase Edge Functions for server-side logic
- Configure email templates for authentication emails
