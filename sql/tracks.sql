--tracks are stored in the raw layer as a BQ table in the form of plain json text.
--The query below extracts the required fields from the raw layer data
SELECT
  extract_timestamp,
  JSON_QUERY(track,'$.tracks[0].id') AS id,
  JSON_QUERY(track,'$.tracks[0].name') AS name,
  JSON_QUERY(track,'$.tracks[0].album.release_date') AS release_date,
  JSON_QUERY(track,'$.tracks[0].uri') AS uri,
  JSON_QUERY(track,'$.tracks[0].duration_ms') AS duration,
  JSON_QUERY(track,'$.tracks[0].popularity') AS track_popularity,
FROM
  `capable-bivouac-325712.tracks_popularity.tracks_at_spotify`