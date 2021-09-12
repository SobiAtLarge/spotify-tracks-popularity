#!/bin/sh
docker build -t resource_provisoner .
docker run resource_provisoner:latest