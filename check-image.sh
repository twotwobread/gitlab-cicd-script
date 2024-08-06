#!/bin/sh

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <image-name> <tag>"
    exit 1
fi

IMAGE=$1
TAG=$2

echo "Check if $IMAGE:$TAG image already been deployed to the Dockerhub"

HTTP_CODE=$(wget --server-response --spider "https://hub.docker.com/v2/repositories/$IMAGE/tags/$TAG?page_size=100" 2>&1 | grep "HTTP/" | awk '{print $2}' | head -n 1)
echo "HTTP_CODE: $HTTP_CODE"
echo $HTTP_CODE > http_code.txt
