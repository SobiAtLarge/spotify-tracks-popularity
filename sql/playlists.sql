--Data model for play lists
--The data model consists of three fields, extraction_date, playlist_id,
--and an array of track_ids This is essentially what can be fetched from the Spotify
--Playlists API (https://developer.spotify.com/documentation/web-api/reference/playlists/),
--Specified under "Get a Playlist's Items". Additional dimensional data could also be
--fetched for individual playlists, but that will not been needed to solve the assignment
--Below are some example rows, used for validating the output of queries.
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