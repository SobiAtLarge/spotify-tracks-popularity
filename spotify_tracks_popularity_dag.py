import datetime
import os
import ast

from airflow import models
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator

PROJECT = os.environ.get("PROJECT_ID")

DAG_START_DAY = datetime.datetime(2021, 2, 1)

default_dag_args = {'start_date': DAG_START_DAY,'provide_context': True}

with models.DAG(
        dag_id='spotify_tracks_popularity_dag_v1.0',
        schedule_interval='0 5 * * *',
        default_args=default_dag_args) as dag:
    extraction_app = KubernetesPodOperator(
        task_id='extraction_app',
        namespace='default',
        name='extraction_app',
        #cmds=['./docker_entrypoint.sh', 'args', ENV],
        get_logs=True,
        is_delete_operator_pod=True,
        image=f'europe-west1-docker.pkg.dev/{PROJECT}/spotify-tracks-popularity/extraction-app:latest',
        image_pull_policy='Always',
        env_vars={'TRACK_ID': '1Ku0J6YIKWOd6pZi4VlFLb', 'GCP_PROJECT_ID':PROJECT},
        dag=dag)