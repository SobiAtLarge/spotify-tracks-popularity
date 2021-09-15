// Configure the Google Cloud provider
locals {
    project_id="capable-bivouac-325712"
}

terraform {
  backend "gcs" {
    bucket = "capable-bivouac-325712-tf-state"
    prefix = "state"
    credentials = "CREDENTIALS_FILE.json"
  }
}

provider "google" {
 credentials = file("CREDENTIALS_FILE.json")
 project     = local.project_id
 region      = "eu-west1"
} 

provider "google-beta" {
 credentials = file("CREDENTIALS_FILE.json")
 project     = local.project_id
 region      = "eu-west1"
}

### Enable APIs
resource "google_project_service" "project_iam_service" {
  service                    = "iam.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "project_composer_service" {
  service                    = "composer.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "project_api_service" {
  service                    = "iap.googleapis.com"
  disable_dependent_services = true
}

### Service Accounts
resource "google_service_account" "composer_service_account" {
  account_id   = "composer"
  display_name = "Cloud Composer worker service account"
  depends_on   = [google_project_service.project_iam_service]
}

# Artifact registry

resource "google_artifact_registry_repository" "artifact_repository" {
  provider      = google-beta
  project       = local.project_id
  location      = "europe-west1"
  repository_id = "spotify-tracks-popularity"
  format        = "DOCKER"
}

# Wrapping gcloud commands for building docker image
resource "null_resource" "extraction_app_docker_image" {  
  # Trigger this functonality every time
  triggers = {
    build_number = "${timestamp()}"
  }
  # This part will be executed when a normal terraform apply command is issued
  provisioner "local-exec" {  
    command =  "gcloud builds submit --tag europe-west1-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.artifact_repository.repository_id}/extraction-app:latest"
    interpreter=["sh", "-c"]
    working_dir = path.module  
  }
  depends_on = [google_artifact_registry_repository.artifact_repository]
}

### IAM
resource "google_project_iam_member" "composer_bigquery_admin" {
  role       = "roles/bigquery.admin"
  member     = "serviceAccount:${google_service_account.composer_service_account.email}"
  depends_on = [google_service_account.composer_service_account]
}

resource "google_project_iam_member" "the_access_composer_worker" {
  role       = "roles/composer.worker" # needed for creating composer itself
  member     = "serviceAccount:${google_service_account.composer_service_account.email}"
  depends_on = [google_service_account.composer_service_account]
}

### Buckets

resource "google_storage_bucket" "landing_zone" {
  project       = local.project_id
  name          = "capable-bivouac-landing-zone"
  location      = "EU"
  force_destroy = true
}

#### Bucket access
resource "google_storage_bucket_iam_member" "composer_landing_zone_member" {
  bucket     = google_storage_bucket.landing_zone.name
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${google_service_account.composer_service_account.email}"
  depends_on = [google_storage_bucket.landing_zone, google_service_account.composer_service_account]
}

#### BQ datasets
resource "google_bigquery_dataset" "tracks_popularity" {
  dataset_id                 = "tracks_popularity"
  friendly_name              = "Spotify tracks popularity"
  description                = "Spotify tracks popularity"
  location                   = "EU"
  project                    = local.project_id
  delete_contents_on_destroy = true
}

resource "google_bigquery_table" "tracks_at_spotify" {
  dataset_id  = google_bigquery_dataset.tracks_popularity.dataset_id
  table_id    = "tracks_at_spotify"
  project     = local.project_id
  deletion_protection = true
  schema      = file("sql/tracks_at_spotify_schema.json")
}

resource "google_bigquery_table" "tracks" {
  dataset_id  = google_bigquery_dataset.tracks_popularity.dataset_id
  table_id    = "tracks"
  project     = local.project_id
  deletion_protection = false
  view {
    query = replace(file("sql/tracks.sql"),"#PROJECT_ID",local.project_id)
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.tracks_at_spotify]  
}

resource "google_bigquery_table" "playlists" {
  dataset_id  = google_bigquery_dataset.tracks_popularity.dataset_id
  table_id    = "playlists"
  project     = local.project_id
  deletion_protection = false
  view {
    query = file("sql/playlists.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "all_tracks_in_playlist_during" {
  dataset_id  = google_bigquery_dataset.tracks_popularity.dataset_id
  table_id    = "all_tracks_in_playlist_during"
  project     = local.project_id
  deletion_protection = false
  view {
    query = replace(file("sql/all_tracks_in_playlist_during.sql"),"#PROJECT_ID",local.project_id)
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.playlists]  
}

resource "google_bigquery_table" "historical_track_playlist_membership" {
  dataset_id  = google_bigquery_dataset.tracks_popularity.dataset_id
  table_id    = "historical_track_playlist_membership"
  project     = local.project_id
  deletion_protection = false
  view {
    query = replace(file("sql/historical_track_playlist_membership.sql"),"#PROJECT_ID",local.project_id)
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_table.playlists]  
}


resource "google_composer_environment" "dp-composer" {
  count  = 1
  name   = "dp-composer"
  region = "europe-west1"

  config {
    node_count = 3

    node_config {
      zone            = "europe-west1-b"
      machine_type    = "n1-standard-2"
      service_account = google_service_account.composer_service_account.email
    }

    software_config {
      airflow_config_overrides = {
        core-dags_are_paused_at_creation = "True"
        core-parallelism                 = 3
        # maximum active tasks anywhere
        core-dag_concurrency = 5
        # maximum tasks that can be scheduled at once, per DAG
        core-logging_level        = "DEBUG"
        celery-worker_concurrency = 3
        # maximum tasks that each worker can run at any given time
        scheduler-catchup_by_default = "False"
      }

      env_variables = {
        PROJECT_ID              = local.project_id
      }

      image_version  = "composer-1.14.0-airflow-1.10.10"
      python_version = "3"
    }
  }

  depends_on = [
    google_project_service.project_composer_service,
    google_service_account.composer_service_account,
    google_project_iam_member.the_access_composer_worker]
}

# Wrapping gcloud commands deploying the airflow dag
resource "null_resource" "deploy-airflow-dag" {  
  # Trigger this functonality when the dag has changed
  triggers = {
    chksm_vls = filemd5("spotify_tracks_popularity_dag.py")
  }
  # This part will be executed when a normal terraform apply command is issued
  provisioner "local-exec" {  
    command = "gcloud composer environments storage dags import --environment dp-composer --location europe-west1 --source spotify_tracks_popularity_dag.py"
    interpreter=["sh", "-c"]
    working_dir = path.module  
  }
  depends_on = [google_composer_environment.dp-composer]
}
