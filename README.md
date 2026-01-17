# PMS2 OTT - Flutter Video Streaming App

A premium video streaming application that plays videos from AWS S3, stores metadata in Supabase, and fetches movie information from TMDB.

## Features

- 🎬 **Video Streaming** - Stream videos from AWS S3
- 🎨 **Premium UI** - Netflix-inspired dark theme with smooth animations
- 📱 **Cross-platform** - Runs on Android, iOS, Windows, macOS, Linux
- 💾 **Offline Support** - Cache movies for offline viewing using Hive
- 📝 **Playlists** - Create and manage custom playlists
- ⏯️ **Continue Watching** - Resume from where you left off
- 🔍 **Search** - Search movies by title
- ⚙️ **Settings** - Theme toggle, video quality, cache management

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.0.0 or higher)
- Supabase account
- TMDB API key
- AWS S3 bucket (for video hosting)

### Android Setup
- **MinSDK**: This project requires `minSdk = 24` to support `media_kit`. This is already configured in `android/app/build.gradle.kts`.

### 2. Configuration

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Fill in your API keys in `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   TMDB_API_KEY=your-tmdb-api-key-here
   S3_BUCKET_URL=https://your-bucket.s3.amazonaws.com
   ```

### 3. Database Setup

1. Go to your Supabase project's SQL Editor
2. Run the contents of `supabase_schema.sql` to create all tables
3. Optionally, uncomment the sample data section to add test movies

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Build for Windows
flutter build windows --release

# Build for Android
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app shell with navigation
├── core/
│   ├── config/                  # Environment & Supabase config
│   └── theme/                   # App theme & colors
├── data/
│   ├── models/                  # Data models (Movie, Playlist, etc.)
│   └── services/                # API services (TMDB, Supabase, Offline)
├── features/
│   ├── home/                    # Home screen with featured content
│   ├── player/                  # Video player with Chewie
│   ├── playlists/               # Playlist management
│   ├── search/                  # Search functionality
│   ├── settings/                # App settings
│   └── my_list/                 # User's saved movies
└── shared/
    └── widgets/                 # Reusable widgets
```

## Adding Movies

### Using TMDB API

1. Find the movie on [themoviedb.org](https://www.themoviedb.org)
2. Copy the TMDB movie ID from the URL
3. Upload your video to S3 and get the URL
4. Use the `SupabaseService.addMovie()` method:

```dart
await SupabaseService().addMovie(
  tmdbId: 550,  // Fight Club
  s3VideoUrl: 'https://your-bucket.s3.amazonaws.com/fight-club.mp4',
);
```

### Manual Insert

Insert directly into Supabase:

```sql
INSERT INTO movies (tmdb_id, title, s3_video_url, genres)
VALUES (550, 'Fight Club', 'https://your-s3-url/movie.mp4', ARRAY['Drama', 'Thriller']);
```

## Technologies Used

- **Flutter** - Cross-platform framework
- **Provider** - State management
- **Supabase** - Backend as a Service
- **TMDB API** - Movie metadata
- **AWS S3** - Video storage
- **Chewie/video_player** - Video playback
- **Hive** - Offline storage
- **Dio** - HTTP client

## License

This project is licensed under the MIT License.
