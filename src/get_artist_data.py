import json
import os
import time
import datetime

from spotifyclient import SpotifyClient

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

    print(json.dumps(tracks))    

if __name__ == "__main__":
    main()