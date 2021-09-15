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
    GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID")

    if CLIENT_ID == '' or CLIENT_SECRET == '' or TRACK_IDs == '' or GCP_PROJECT_ID == '':
        print('missing one or more environment varibles: CLIENT_ID, CLIENT_SECRET, TRACK_IDs, GCP_PROJECT_ID')
        exit(1)
    
    BASE_URL = 'https://api.spotify.com/v1/'
    AUTH_URL = 'https://accounts.spotify.com/api/token'

    spotify_client = SpotifyClient(CLIENT_ID,
                                CLIENT_SECRET,
                                BASE_URL,
                                AUTH_URL)

    ts = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')
    filename = 'tracks.json'
    with open(filename, 'a') as file:
        # One API call for every track,
        # This is to avoid mixing inconsistant json responses into one row
        # Also no need for unnesting in BQ
        for track_id in TRACK_IDs.split(','):
            track_data= spotify_client.get_tracks([track_id])
            track_json_string = json.dumps(track_data)
            track_table_row = {
                "track_id":track_id,
                "extract_timestamp":ts,
                "track_data":track_json_string}
            file.write(json.dumps(track_table_row))
            file.write("\n")
    
    upload_file_to_bq(
        filename=filename,
        project_id=GCP_PROJECT_ID,
        dataset_id='tracks_popularity',
        table_id='tracks_at_spotify')

if __name__ == "__main__":
    main()