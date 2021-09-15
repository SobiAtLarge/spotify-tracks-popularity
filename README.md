# Intorduction
A data engineering assignment that extracts data about a given set of tracks from Spotify public APIs.

# Implementation overview
Terraform is used for deploying components to GCP. Terraform itself runs inside a local docker container, with a docker file in `Dockerfile`.
Here is the list of components:
1. A containerized application that queries Spotify APIs and write the results to a table in BigQuery. The docker file for this application is `ExtractionAppDockerfile`.
2. Google Artifact Registry for hosting the image.
3. Cloud Composer (Airflow) that runs the container in a dag.
4. SQL views for data modeling.

# Setup
## Prerequisits:
To install and deploy components, you need to have Docker, and owner access to a GCP project.
## Configuration steps:
1. If needed, create a new GCP project.
2. Create a service account with project owner access, create a key for it and download it. Place the key file in the spotify-tracks-popularity root folder and name it `CREDENTIALS_FILE.json`.
3. Create the terraform a GCS bucket used for terraform state
4. Edit the terraform file `main.tf`; Change the variables `project_id="capable-bivouac-325712"` and `bucket = "capable-bivouac-325712-tf-state"` to reflect your GCP project id and the GCS bucket you created above. 
5. Edit the file `docker_entrypoint.sh` and place the email address of the service account you created in the line
`gcloud auth activate-service-account  "resource-provisioner@capable-bivouac-325712.iam.gserviceaccount.com" --key-file=CREDENTIALS_FILE.json`

## deployment
Run the following commands in succession:
1. `docker build -t resource_provisoner .`
2. `docker run resource_provisoner:latest`
The container-based deployment creates all GCP resources, deploys the image for python app to artifact registry, and deploys the Airflow dag.
All artifacts that need deploying are copied into the Terraform container. From there, the GCP resources are created, the app image is built and pushed to Artifact regisrty, and the Airflow dag is deployed.

## How to run
1. In GCP console, navigate to Composer environments, and open the Airflow UI.
2. Enable the dag `spotify_tracks_popularity_dag`, which would make an initial run.
3. The initial run might fail as the image might take too long to load for the first time, in that case clear the task named `extraction_app` to run it again.
4. To see the data and run the queries, navigate to BigQuery in cloud console and query the table/views.
# References
The Spotify client code was partially taken from here: https://github.com/dmschauer/spotify-api-historization