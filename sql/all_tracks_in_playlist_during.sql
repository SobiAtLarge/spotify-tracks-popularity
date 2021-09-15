--Answers the first query in section2:
--What tracks have been in a playlist during a specific time period.
SELECT
    p.playlist_id,
    ARRAY_AGG(DISTINCT track) AS tracks
FROM
    `#PROJECT_ID.tracks_popularity.playlists` p,
    UNNEST(tracks) track
WHERE
    --during a specific time period, e.g. from 2020-01-01 to 2020-01-02
    extraction_date BETWEEN DATE('2020-01-01') AND DATE('2020-01-02')
GROUP BY
    1
