--Data model for play lists and the two queries requested
--The data model consists of three fields, extraction_date, playlist_id, and an array of track_ids
WITH playlists AS(
    SELECT DATE('2020-01-01') AS extraction_date,'p1' AS playlist_id,['t1','t2','t3'] AS tracks
    UNION ALL
    SELECT DATE('2020-01-01') AS extraction_date,'p2' AS playlist_id,['t3','t4','t5'] AS tracks
    UNION ALL
    SELECT DATE('2020-01-02') AS extraction_date,'p1' AS playlist_id,['t1','t2'] AS tracks
    UNION ALL
    SELECT DATE('2020-01-02') AS extraction_date,'p2' AS playlist_id,['t3','t4','t5','t6'] AS tracks
    UNION ALL
    SELECT DATE('2020-01-03') AS extraction_date,'p1' AS playlist_id,['t3','t5'] AS tracks
    UNION ALL
    SELECT DATE('2020-01-03') AS extraction_date,'p2' AS playlist_id,['t4','t6'] AS tracks    
    UNION ALL
    SELECT DATE('2020-01-04') AS extraction_date,'p1' AS playlist_id,['t3','t5'] AS tracks
    UNION ALL
    SELECT DATE('2020-01-04') AS extraction_date,'p2' AS playlist_id,['t4','t5','t6'] AS tracks    
),
--This CTE answers the first query in section2:
--What tracks have been in a playlist during a specific time period.
tracks_of_playlist_during AS(
    SELECT
        p.playlist_id,
        ARRAY_AGG(DISTINCT track)
    FROM
        playlists p, UNNEST(tracks) track
    WHERE
        --during a specific time period, e.g.
        extraction_date BETWEEN DATE('2020-01-01') AND DATE('2020-01-02')
    GROUP BY
        1
),
track_belonging_to_playlist AS(
    SELECT
    track,
    playlist_id,
    extraction_date,
    LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date) AS latest_past_day_in_playlist,
    COALESCE(DATE_DIFF(extraction_date,LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date),DAY),1) AS diff_to_latest_past_date,
    CASE
      WHEN
        -- first day on a playlist
        LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date) IS NULL
        --the previous appearance on this playlist was more than one day ago
        OR DATE_DIFF(extraction_date, LAG(extraction_date) OVER(PARTITION BY track,playlist_id ORDER BY extraction_date), DAY) > 1
      THEN 1
      ELSE 0
    END AS is_fresh_appearance
  FROM
    playlists p, UNNEST(tracks) track
),
track_belonging_to_playlist_appear_sequenced AS
(SELECT
    track,
    playlist_id,
    extraction_date,
    SUM(is_fresh_appearance) OVER (PARTITION BY track, playlist_id ORDER BY extraction_date) as appearance_sequence_number
FROM
    track_belonging_to_playlist
ORDER BY
    track,playlist_id,extraction_date
),
--This CTE answers the second query in section 2:
--In which playlists a given track has been and during what periods of time.
track_belonging_to_playlist_history AS(
SELECT
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
ORDER BY
    1,
    2,
    3
)
SELECT
    *
FROM 
    track_belonging_to_playlist_history