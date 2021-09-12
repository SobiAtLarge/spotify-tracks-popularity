import json
import requests

class SpotifyClient:
    """Stablishes a connection to spotify and queries APIs."""

    def __init__(self, client_id, client_secret, base_url, auth_url):
        """
        :param client_id (str): Client ID of the Spotify app
        :param client_secret (str): Client secret of the Spotify app
        :param base_url (str): base URL of all Spotify Web API endpoints
        :param auth_url (str): Authentication URL
        """
        self._client_id = client_id
        self._client_secret = client_secret
        self._base_url = base_url
        self._auth_url = auth_url

        self._access_token = self.get_access_token()

    def get_access_token(self):
        """
        -Authenticates with spotify AP
        -Saves access token

        :return access_token (str): Access token for supplied Client ID (Spotify for Developers App)
        """
        auth_response = requests.post(self._auth_url, {
            'grant_type': 'client_credentials',
            'client_id': self._client_id,
            'client_secret': self._client_secret,
        })
        auth_response_data = auth_response.json()
        access_token = auth_response_data['access_token']

        return access_token

    def _place_get_api_request(self, url, params):
        response = requests.get(
            url,
            headers={
                "Content-Type": "application/json",
                "Authorization": "Bearer {token}".format(token=self._access_token)
            },
            params=params
        )
        return response

    def _place_post_api_request(self, url, data):
        response = requests.post(
            url,
            data=data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {self._authorization_token}"
            }
        )
        return response
    
    def get_tracks(self, track_ids):
        url = self._base_url + 'tracks/'
        params={'ids': track_ids}
        response = self._place_get_api_request(url, params)
        response_json = response.json()

        return response_json