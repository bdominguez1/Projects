CREATE TABLE Artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(250) NOT NULL
);

CREATE TABLE Tracks (
    track_id VARCHAR(60) PRIMARY KEY,
    track_name VARCHAR(250),
    album_name VARCHAR(250),
    release_date DATE,
    popularity INT,
    explicit BOOLEAN,
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

CREATE TABLE StreamingMetrics (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    track_id VARCHAR(60),
    spotify_streams BIGINT,
    youtube_views BIGINT,
    tiktok_views BIGINT,
    airplay_spins INT,
    shazam_counts INT,
    FOREIGN KEY (track_id) REFERENCES Tracks(track_id)
);