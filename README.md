# Intorduction
A data engineering assignment that extracts data about a given set of tracks from Spotify public APIs.

#  Components
Main components of this solution:
1-Infrastructure as code using terraform
2-Extraction python app, packaged in a docker container
3-Airflow orchestration tool
4-SQL logic

# Setup
## Prerequisits:
To install and deploy thins, you need to have Docker, and access to a GCP project.
## steps:
1. Create a service account with editor access, create a key for it and download it into a file named CREDENTIALS_FILE.json.
2. Create the terraform remote state bucket and place its name in XX

# deployment
Run the following commands in succession:
1. docker build -t resource_provisoner .
2. docker run resource_provisoner:latest
The app code is placed into the container, so after any change in the code, the image has to be rebuilt.

# References
The Spotify client code was taken from here: https://github.com/dmschauer/spotify-api-historization
