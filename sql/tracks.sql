--tracks are stored in the raw layer as a BQ table in the form of plain json text.
--The tracks raw data model is in the tracks_at_spotify table, with three fields,
--extract_timestamp, track_id, which records the track_id in the request, and 
--track_data that contains the whole JSON response from the spotify API.
--The query below extracts the required fields from the raw layer data
with tag_invalid_track_data AS(
  SELECT
  extract_timestamp,
  track_id AS track_id_in_request,
  IF(track_data = '{"error": {"status": 400, "message": "invalid id"}}',TRUE,FALSE) AS invalid_id,
  JSON_QUERY(track_data,'$.tracks[0].id') AS id,
  JSON_QUERY(track_data,'$.tracks[0].name') AS name,
  JSON_QUERY(track_data,'$.tracks[0].album.release_date') AS release_date,
  JSON_QUERY(track_data,'$.tracks[0].uri') AS uri,
  JSON_QUERY(track_data,'$.tracks[0].duration_ms') AS duration,
  JSON_QUERY(track_data,'$.tracks[0].popularity') AS track_popularity,
FROM
  `#PROJECT_ID.tracks_popularity.tracks_at_spotify`
)
SELECT
  * EXCEPT(invalid_id)
FROM
  tag_invalid_track_data
WHERE
  invalid_id = FALSE