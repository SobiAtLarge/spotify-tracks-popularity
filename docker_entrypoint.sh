#!/bin/sh
gcloud auth activate-service-account  "resource-provisioner@capable-bivouac-325712.iam.gserviceaccount.com" --key-file=CREDENTIALS_FILE.json
terraform init
terraform apply -auto-approve