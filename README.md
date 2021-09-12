# What is this?
This is where infrastructure is maintained
the docker file is used as 

# Setup steps:
Create service accounts, create a key for it and download it.
create state bucket 
terraform remote state bucket

# deployment:
Run the following commands in succession:
1-docker build -t resource_provisoner .
2-docker run resource_provisoner:latest
The code is placed into the container, so after any change in the code, the image has to be rebuilt.

Problem:
Define provisioner service account in one place only, and use it every where, it is now in the entry poinbt too



Overall README:


# What is this?
This folder consists of the app code for extracting data from Spotify APIs.

#  Components
 There are three subfolders in this repository, each could be seen as a separate repo, but for simplicity they are all kept in the same repository. 
 Infra folder; this is the component where GCP resources are defined as code

# Setup steps
prerequisits: Docker
First the infra needs to be provisioned as described in [link to README.md in infra]
Then 

# References / Credits
https://github.com/dmschauer/spotify-api-historization
