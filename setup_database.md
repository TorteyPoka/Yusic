# Quick Database Setup

## ⚠️ IMPORTANT: You need to create database tables first!

The error you're seeing means the database tables don't exist yet in Supabase.

## Quick Fix Steps:

### 1. Open Supabase Dashboard
Go to: https://app.supabase.com/project/vkrmpzjjwsmqcyakjeag

### 2. Go to SQL Editor
- Click on "SQL Editor" in the left sidebar
- Click "New Query"

### 3. Copy and Paste This SQL
Run this SQL in one go:

```sql
-- Create Users Table
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

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Anyone can insert users"
  ON users FOR INSERT
  WITH CHECK (true);

-- Create Folders Table
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

-- Create Tracks Table
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

-- Create Bookings Table
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

### 4. Click "Run" button

You should see success messages for each table created.

### 5. Try Registration Again

Go back to your app at http://localhost:8082 and try registering again!

---

## ✅ Verification

After running the SQL, you can verify the tables exist:
1. Go to "Table Editor" in Supabase
2. You should see: users, folders, tracks, bookings

## Need Help?

If you see any errors when running the SQL:
- Make sure you're in the right project
- Check if tables already exist (you might need to drop them first)
- Contact support if issues persist
