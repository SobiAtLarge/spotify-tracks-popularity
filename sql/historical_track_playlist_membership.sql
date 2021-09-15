--Answers the second query in section2:
--In which playlists a given track has been and during what periods of time.
WITH track_belonging_to_playlist AS(
    SELECT
    track,
    playlist_id,
    extraction_date,
    LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date) AS latest_past_day_in_playlist,
    COALESCE(DATE_DIFF(extraction_date,LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date),DAY),1) AS diff_to_latest_past_date,
    --Detects when a track appears on a playlist for the first time,
    -- or if it reappears after a gap of one or more days
    CASE
      WHEN
        -- First day on a playlist
        LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date) IS NULL
        -- The previous appearance on this playlist was more than one day ago
        OR DATE_DIFF(extraction_date, LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date), DAY) > 1
      THEN 1
        -- The track has been on this playlist on the day before, so it is not a fresh appearance
      ELSE 0
    END AS is_fresh_appearance
  FROM
    `#PROJECT_ID.tracks_popularity.playlists` p,
    UNNEST(tracks) track
),
track_belonging_to_playlist_appear_sequenced AS
(SELECT
    track,
    playlist_id,
    extraction_date,
    --Assigns a sequence number for every time a track appears in a certain playlist for consecutive days
    SUM(is_fresh_appearance) OVER (PARTITION BY track, playlist_id ORDER BY extraction_date) as appearance_sequence_number
FROM
    track_belonging_to_playlist
), historical_track_playlist_membership AS
(SELECT
    track,
    playlist_id,
    appearance_sequence_number,
    MIN(extraction_date) AS started_to_appear, 
    MAX(extraction_date) AS ended_to_appear, 
FROM
    track_belonging_to_playlist_appear_sequenced
GROUP BY
    1,
    2,
    3
)
SELECT
    track,
    playlist_id,
    started_to_appear, 
    ended_to_appear
FROM
    historical_track_playlist_membership
--Sort the set for validating the output in this small example
ORDER BY
    1,
    2,
    3