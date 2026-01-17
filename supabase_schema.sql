-- PMS2 OTT Database Schema for Supabase
-- Run this in your Supabase SQL Editor
-- This script is idempotent - safe to run multiple times

-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- MOVIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS movies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tmdb_id INTEGER UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    poster_url TEXT,
    backdrop_url TEXT,
    s3_video_url TEXT NOT NULL,
    duration INTEGER, -- in seconds
    release_date DATE,
    rating DECIMAL(3,1),
    genres TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster genre searches
CREATE INDEX IF NOT EXISTS idx_movies_genres ON movies USING GIN (genres);
CREATE INDEX IF NOT EXISTS idx_movies_tmdb_id ON movies (tmdb_id);

-- Enable RLS on movies table
ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first to avoid conflicts
DROP POLICY IF EXISTS "Movies are viewable by everyone" ON movies;
DROP POLICY IF EXISTS "Movies are insertable by authenticated users" ON movies;
DROP POLICY IF EXISTS "Movies are updatable by authenticated users" ON movies;

-- Create RLS policies for movies
CREATE POLICY "Movies are viewable by everyone" ON movies
    FOR SELECT USING (true);

CREATE POLICY "Movies are insertable by authenticated users" ON movies
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Movies are updatable by authenticated users" ON movies
    FOR UPDATE USING (true);

-- ============================================
-- PLAYLISTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS playlists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on playlists table
ALTER TABLE playlists ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first
DROP POLICY IF EXISTS "Playlists are viewable by everyone" ON playlists;
DROP POLICY IF EXISTS "Playlists are insertable by everyone" ON playlists;
DROP POLICY IF EXISTS "Playlists are updatable by everyone" ON playlists;
DROP POLICY IF EXISTS "Playlists are deletable by everyone" ON playlists;

-- Create RLS policies for playlists
CREATE POLICY "Playlists are viewable by everyone" ON playlists
    FOR SELECT USING (true);

CREATE POLICY "Playlists are insertable by everyone" ON playlists
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Playlists are updatable by everyone" ON playlists
    FOR UPDATE USING (true);

CREATE POLICY "Playlists are deletable by everyone" ON playlists
    FOR DELETE USING (true);

-- ============================================
-- PLAYLIST_MOVIES TABLE (Junction table)
-- ============================================
CREATE TABLE IF NOT EXISTS playlist_movies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    playlist_id UUID NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
    movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    position INTEGER NOT NULL DEFAULT 0,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(playlist_id, movie_id)
);

CREATE INDEX IF NOT EXISTS idx_playlist_movies_playlist ON playlist_movies(playlist_id);
CREATE INDEX IF NOT EXISTS idx_playlist_movies_movie ON playlist_movies(movie_id);

-- Enable RLS
ALTER TABLE playlist_movies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first
DROP POLICY IF EXISTS "Playlist movies are viewable by everyone" ON playlist_movies;
DROP POLICY IF EXISTS "Playlist movies are insertable by everyone" ON playlist_movies;
DROP POLICY IF EXISTS "Playlist movies are deletable by everyone" ON playlist_movies;

-- Create RLS policies
CREATE POLICY "Playlist movies are viewable by everyone" ON playlist_movies
    FOR SELECT USING (true);

CREATE POLICY "Playlist movies are insertable by everyone" ON playlist_movies
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Playlist movies are deletable by everyone" ON playlist_movies
    FOR DELETE USING (true);

-- ============================================
-- USER_PROGRESS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    watch_position INTEGER NOT NULL DEFAULT 0, -- in seconds
    is_completed BOOLEAN DEFAULT false,
    last_watched TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, movie_id)
);

CREATE INDEX IF NOT EXISTS idx_user_progress_user ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_movie ON user_progress(movie_id);

-- Enable RLS
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first
DROP POLICY IF EXISTS "User progress is viewable by everyone" ON user_progress;
DROP POLICY IF EXISTS "User progress is insertable by everyone" ON user_progress;
DROP POLICY IF EXISTS "User progress is updatable by everyone" ON user_progress;

-- Create RLS policies
CREATE POLICY "User progress is viewable by everyone" ON user_progress
    FOR SELECT USING (true);

CREATE POLICY "User progress is insertable by everyone" ON user_progress
    FOR INSERT WITH CHECK (true);

CREATE POLICY "User progress is updatable by everyone" ON user_progress
    FOR UPDATE USING (true);

-- ============================================
-- USER_MY_LIST TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_my_list (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    movie_id UUID NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, movie_id)
);

CREATE INDEX IF NOT EXISTS idx_user_my_list_user ON user_my_list(user_id);

-- Enable RLS
ALTER TABLE user_my_list ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first
DROP POLICY IF EXISTS "User list is viewable by everyone" ON user_my_list;
DROP POLICY IF EXISTS "User list is insertable by everyone" ON user_my_list;
DROP POLICY IF EXISTS "User list is deletable by everyone" ON user_my_list;

-- Create RLS policies
CREATE POLICY "User list is viewable by everyone" ON user_my_list
    FOR SELECT USING (true);

CREATE POLICY "User list is insertable by everyone" ON user_my_list
    FOR INSERT WITH CHECK (true);

CREATE POLICY "User list is deletable by everyone" ON user_my_list
    FOR DELETE USING (true);

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers first
DROP TRIGGER IF EXISTS update_movies_updated_at ON movies;
DROP TRIGGER IF EXISTS update_playlists_updated_at ON playlists;

-- Create triggers for updated_at
CREATE TRIGGER update_movies_updated_at
    BEFORE UPDATE ON movies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_playlists_updated_at
    BEFORE UPDATE ON playlists
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VERIFICATION
-- ============================================
SELECT 'Schema setup complete!' as status;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
