FROM hashicorp/terraform:0.12.31
 
RUN apk add --update --no-cache curl python3 && \
    ln -sf python3 /usr/bin/python && \
    curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz && \
    mkdir -p /usr/local/gcloud && \
    tar -C /usr/local/gcloud -xf /tmp/google-cloud-sdk.tar.gz && \
    ln -s /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/bin/gcloud && \
    /usr/local/gcloud/google-cloud-sdk/install.sh && \
    gcloud config set project capable-bivouac-325712
 
 WORKDIR /provisioning

 COPY ExtractionAppDockerfile /provisioning/Dockerfile
 COPY main.tf /provisioning
 COPY docker_entrypoint.sh /provisioning
 COPY CREDENTIALS_FILE.json /provisioning
 COPY requirements.txt /provisioning
 COPY ./src /provisioning/src

ENTRYPOINT ["/bin/sh", "docker_entrypoint.sh"]
