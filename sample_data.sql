-- Sample Movie Data for PMS2 OTT
-- Run this after the main supabase_schema.sql

-- Clear existing sample data (optional - uncomment if needed)
-- DELETE FROM movies;

-- Insert sample movies with TMDB IDs and placeholder S3 URLs
-- Replace the S3 URLs with your actual video URLs

INSERT INTO movies (tmdb_id, title, description, poster_url, backdrop_url, s3_video_url, duration, release_date, rating, genres)
VALUES 
-- Action Movies
(299536, 'Avengers: Infinity War', 
 'The Avengers and their allies must be willing to sacrifice all in an attempt to defeat the powerful Thanos before his blitz of devastation and ruin puts an end to the universe.',
 'https://image.tmdb.org/t/p/w500/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg',
 'https://image.tmdb.org/t/p/w1280/bOGkgRGdhrBYJSLpXaxhXVstddV.jpg',
 'https://s3.in-west3.purestore.io/sample/avengers-infinity-war.mp4',
 8940, '2018-04-25', 8.3, ARRAY['Action', 'Adventure', 'Science Fiction']),

(299534, 'Avengers: Endgame',
 'After the devastating events of Avengers: Infinity War, the universe is in ruins. With the help of remaining allies, the Avengers assemble once more in order to reverse Thanos'' actions and restore balance to the universe.',
 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
 'https://image.tmdb.org/t/p/w1280/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
 'https://s3.in-west3.purestore.io/sample/avengers-endgame.mp4',
 10860, '2019-04-24', 8.3, ARRAY['Action', 'Adventure', 'Science Fiction']),

(24428, 'The Avengers',
 'When an unexpected enemy emerges and threatens global safety and security, Nick Fury, director of the international peacekeeping agency known as S.H.I.E.L.D., finds himself in need of a team to pull the world back from the brink of disaster.',
 'https://image.tmdb.org/t/p/w500/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg',
 'https://image.tmdb.org/t/p/w1280/hbn46fQaRmlpBuUrEiFqv0GDL6Y.jpg',
 'https://s3.in-west3.purestore.io/sample/the-avengers.mp4',
 8580, '2012-04-25', 7.7, ARRAY['Action', 'Adventure', 'Science Fiction']),

-- Drama Movies
(278, 'The Shawshank Redemption',
 'Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an pointy warden.',
 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
 'https://image.tmdb.org/t/p/w1280/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg',
 'https://s3.in-west3.purestore.io/sample/shawshank-redemption.mp4',
 8520, '1994-09-23', 8.7, ARRAY['Drama', 'Crime']),

(238, 'The Godfather',
 'Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family. When organized crime family patriarch, Vito Corleone barely survives an attempt on his life, his youngest son, Michael steps in to take care of the would-be killers.',
 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
 'https://image.tmdb.org/t/p/w1280/tmU7GeKVybMWFButWEGl2M4GeiP.jpg',
 'https://s3.in-west3.purestore.io/sample/the-godfather.mp4',
 10500, '1972-03-14', 8.7, ARRAY['Drama', 'Crime']),

-- Thriller Movies
(550, 'Fight Club',
 'A ticking-Loss bomb of a story about rebellion, identity, and the search for meaning in a consumer-driven society. An insomniac office worker and a devil-may-care soap maker form an underground fight club that evolves into something much, much more.',
 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
 'https://image.tmdb.org/t/p/w1280/87hTDiay2N2qWyX4Ds7ybXi9h8I.jpg',
 'https://s3.in-west3.purestore.io/sample/fight-club.mp4',
 8520, '1999-10-15', 8.4, ARRAY['Drama', 'Thriller']),

(680, 'Pulp Fiction',
 'A burger-loving hit man, his philosophical partner, a drug-addled gangster''s moll and a washed-up boxer converge in this sprawling, comedic crime caper.',
 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
 'https://image.tmdb.org/t/p/w1280/suaEOtk1N1sgg2MTM7oZd2cfVp3.jpg',
 'https://s3.in-west3.purestore.io/sample/pulp-fiction.mp4',
 9240, '1994-09-10', 8.5, ARRAY['Crime', 'Thriller']),

-- Sci-Fi Movies
(27205, 'Inception',
 'Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets is offered a chance to regain his old life as payment for a task considered to be impossible: "inception", the implantation of another person''s idea into a target''s subconscious.',
 'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg',
 'https://image.tmdb.org/t/p/w1280/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
 'https://s3.in-west3.purestore.io/sample/inception.mp4',
 8880, '2010-07-15', 8.4, ARRAY['Action', 'Science Fiction', 'Adventure']),

(603, 'The Matrix',
 'Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.',
 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
 'https://image.tmdb.org/t/p/w1280/fNG7i7RqMErkcqhohV2a6cV1Ehy.jpg',
 'https://s3.in-west3.purestore.io/sample/the-matrix.mp4',
 8160, '1999-03-30', 8.2, ARRAY['Action', 'Science Fiction']),

(157336, 'Interstellar',
 'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
 'https://image.tmdb.org/t/p/w1280/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
 'https://s3.in-west3.purestore.io/sample/interstellar.mp4',
 10140, '2014-11-05', 8.4, ARRAY['Adventure', 'Drama', 'Science Fiction']),

-- Comedy Movies
(508947, 'Turning Red',
 'Thirteen-year-old Mei is experiencing the awkwardness of being a teenager with a twist – when she gets too excited, she transforms into a giant red panda.',
 'https://image.tmdb.org/t/p/w500/qsdjk9oAKSQMWs0Vt5Pyfh6O4GZ.jpg',
 'https://image.tmdb.org/t/p/w1280/fOy2Jurz9k6RnJnMUMRDAgBwru2.jpg',
 'https://s3.in-west3.purestore.io/sample/turning-red.mp4',
 6000, '2022-03-01', 7.4, ARRAY['Animation', 'Family', 'Comedy']),

(438631, 'Dune',
 'Paul Atreides, a brilliant and gifted young man born into a great destiny beyond his understanding, must travel to the most dangerous planet in the universe to ensure the future of his family and his people.',
 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
 'https://image.tmdb.org/t/p/w1280/jYEW5xZkZk2WTrdbMGAPFuBqbDc.jpg',
 'https://s3.in-west3.purestore.io/sample/dune.mp4',
 9360, '2021-09-15', 7.9, ARRAY['Science Fiction', 'Adventure']);

-- Create a sample playlist
INSERT INTO playlists (name, description, thumbnail_url, is_public)
VALUES 
('Must Watch Classics', 'Essential classic movies everyone should see', 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg', true),
('Sci-Fi Marathon', 'Mind-bending science fiction adventures', 'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg', true),
('Marvel Universe', 'Avengers and Marvel superhero movies', 'https://image.tmdb.org/t/p/w500/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg', true);

-- Add movies to playlists (you'll need to update the UUIDs after running the above)
-- This uses a subquery to get the IDs dynamically

-- Must Watch Classics playlist
INSERT INTO playlist_movies (playlist_id, movie_id, position)
SELECT 
    (SELECT id FROM playlists WHERE name = 'Must Watch Classics'),
    id,
    ROW_NUMBER() OVER (ORDER BY rating DESC)
FROM movies 
WHERE title IN ('The Shawshank Redemption', 'The Godfather', 'Pulp Fiction', 'Fight Club');

-- Sci-Fi Marathon playlist
INSERT INTO playlist_movies (playlist_id, movie_id, position)
SELECT 
    (SELECT id FROM playlists WHERE name = 'Sci-Fi Marathon'),
    id,
    ROW_NUMBER() OVER (ORDER BY release_date DESC)
FROM movies 
WHERE 'Science Fiction' = ANY(genres);

-- Marvel Universe playlist
INSERT INTO playlist_movies (playlist_id, movie_id, position)
SELECT 
    (SELECT id FROM playlists WHERE name = 'Marvel Universe'),
    id,
    ROW_NUMBER() OVER (ORDER BY release_date)
FROM movies 
WHERE title LIKE '%Avengers%';

-- Verify the data
SELECT 'Movies inserted:' as info, COUNT(*) as count FROM movies;
SELECT 'Playlists created:' as info, COUNT(*) as count FROM playlists;
SELECT 'Playlist movies linked:' as info, COUNT(*) as count FROM playlist_movies;
