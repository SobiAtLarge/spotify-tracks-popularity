import json
import os
import time
import datetime

from spotifyclient import SpotifyClient
from bigquery_utils import upload_file_to_bq

def main():
    CLIENT_ID = os.getenv("CLIENT_ID")
    CLIENT_SECRET = os.getenv("CLIENT_SECRET")
    TRACK_ID = os.getenv("TRACK_ID")

    BASE_URL = 'https://api.spotify.com/v1/'
    AUTH_URL = 'https://accounts.spotify.com/api/token'

    spotify_client = SpotifyClient(CLIENT_ID,
                                CLIENT_SECRET,
                                BASE_URL,
                                AUTH_URL)

    ts = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')
    
    print("{}: Processing".format(ts))
    
    tracks= spotify_client.get_tracks([TRACK_ID])

    tracks_json_string = json.dumps(tracks)

    timestamped_tracks = {"tracks":tracks_json_string,"extract_timestamp":ts}

    filename = 'tracks.json'

    with open(filename, 'w') as file:
        file.write(json.dumps(timestamped_tracks))

    upload_file_to_bq(
        filename=filename,
        project_id='capable-bivouac-325712',
        dataset_id='tracks_popularity',
        table_id='tracks_at_spotify')

if __name__ == "__main__":
    main()