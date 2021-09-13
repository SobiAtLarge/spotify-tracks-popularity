import json
import os
import time
import datetime

from spotifyclient import SpotifyClient
from bigquery_utils import upload_file_to_bq

def main():
    CLIENT_ID = os.getenv("CLIENT_ID")
    CLIENT_SECRET = os.getenv("CLIENT_SECRET")
    TRACK_IDs = os.getenv("TRACK_ID")

    BASE_URL = 'https://api.spotify.com/v1/'
    AUTH_URL = 'https://accounts.spotify.com/api/token'

    spotify_client = SpotifyClient(CLIENT_ID,
                                CLIENT_SECRET,
                                BASE_URL,
                                AUTH_URL)

    ts = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')
    filename = 'tracks.json'
    with open(filename, 'a') as file:
        for track in TRACK_IDs.split(','):
            track= spotify_client.get_tracks([track])
            track_json_string = json.dumps(track)
            timestamped_tracks = {"track":track_json_string,"extract_timestamp":ts}
            file.write(json.dumps(timestamped_tracks))
            file.write("\n")
    
    upload_file_to_bq(
        filename=filename,
        project_id='capable-bivouac-325712',
        dataset_id='tracks_popularity',
        table_id='tracks_at_spotify')

if __name__ == "__main__":
    main()