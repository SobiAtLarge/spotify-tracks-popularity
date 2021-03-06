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
`gcloud auth activate-service-account  "resource-provisioner@capable-bivouac-325712.iam.gserviceaccount.com" --key-file=CREDENTIALS_FILE.json`. In the same file, also edit project change the project name on the line `gcloud config set project capable-bivouac-325712`

## deployment
Run the following commands in succession:
1. `docker build -t resource_provisoner .`
2. `docker run resource_provisoner:latest`

In case the container fails to connect/download some content, simply run the step 2 above again.
The container-based deployment creates all GCP resources, deploys the image for python app to artifact registry, and deploys the Airflow dag.
All artifacts that need deploying are copied into the Terraform container. From there, the GCP resources are created, the app image is built and pushed to Artifact regisrty, and the Airflow dag is deployed.

## How to run
1. In GCP console, navigate to Composer environments, and open the Airflow UI.
2. Enable the dag `spotify_tracks_popularity_dag`, which would make an initial run.
3. The initial run might fail as the image might take too long to load for the first time, in that case clear the task named `extraction_app` to run it again.
4. To see the data and run the queries, navigate to BigQuery in cloud console and query the table/views.

## How to destroy the infrastructure
Change the docker the last line in `docker_entrypoint.sh` from `terraform apply -auto-approve` to `terraform destroy -auto-approve` and then run the steps in the deployment.

# Notes on how this was developed
## tasks list
1. Get the docker app "working", prints on screen - DONE
2. Get the app to query the correct API end point/content - DONE
3. Setup a GCP project - DONE
4. Terraform composer, BQ dataset, bucket, etc. -- DONE
5. Deploying the app image to artifact registry throgh terraform code -- DONE
6. Composer dag that runs the container -- DONE
7. Modify the docker image/code to write to BQ -- DONE
8. deploying dag to composer using terraform -- DONE
9. One API call for each track in the list of tracks env var to avoid inconsistant responses and unnestings.
10. Data modeling --DONE
11. Write instructions manual for installation/execution --DONE

## Development considerations
1. Schema evolution, that is why the data is kept in raw json format in string.
2. Infra as code, I think is very important for the project at the finance team, thats why I implemented it here.
3. clamity: developing on a windows machine, no local bash, used a docker image for dev/deployment environemnt.
4. NO proper deployments, deployment of the app-image and the dag is done in terraform, not ideal, but quick and dirty- time limitations ...

## Next steps:
1. Setup secret manager for spotify client secrets and service account keys.
2. CI/CD pipelines for the app, sql, dag, and infra code.
3. DBT for proper modeling with layers, dbt can be packaged as a docker container and executed from Airflow.
5. Read all track_ids from a file that is located in a bucket or from a BQ table.

# References
The Spotify client code was partially taken from here: https://github.com/dmschauer/spotify-api-historization
