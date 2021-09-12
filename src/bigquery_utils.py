from google.cloud import bigquery

def upload_file_to_bq(*, filename,project_id,dataset_id,table_id):
    bigquery_client = bigquery.Client(project=project_id, location="EU")
    table_ref = f"{project_id}.{dataset_id}.{table_id}"
    job_config = bigquery.LoadJobConfig()

    job_config.write_disposition = "WRITE_APPEND"
    job_config.create_disposition = "CREATE_IF_NEEDED"

    job_config.source_format = bigquery.SourceFormat.NEWLINE_DELIMITED_JSON
    job_config.autodetect = True

    with open(filename, 'rb') as source_file:
        job = bigquery_client.load_table_from_file(
            source_file, table_ref, job_config=job_config)

    job.result()
