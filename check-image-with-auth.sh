#!/bin/sh

set -e

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <config-json> <registry> <image-path> <tag>"
    exit 1
fi

CONFIG_JSON="$1"
REGISTRY="$2"
IMAGE_PATH="$3"
TAG="$4"


echo "Processing Docker config from variable..."

REGISTRY_BLOCK=$(echo "$CONFIG_JSON" | grep -A 5 "\"$REGISTRY\"")
if [ ! -z "$REGISTRY_BLOCK" ]; then
    AUTH_ENCODED=$(echo "$REGISTRY_BLOCK" | grep -m1 '"auth"' | sed 's/.*"auth"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    echo "Auth extracted."
else
    echo "Registry block not found. Check registry url and config json data"
fi

echo "Found auth for $REGISTRY"


MANIFEST_URL="https://$REGISTRY/v2/$IMAGE_PATH/manifests/$TAG"

echo "Generated Manifest URL: $MANIFEST_URL"

wget --server-response --spider \
    --no-check-certificate \
    --header="Authorization: Bearer $AUTH_ENCODED" \
    --header="Accept: application/vnd.oci.image.manifest.v1+json" \
    "$MANIFEST_URL" 

HTTP_CODE=$(wget --server-response --spider \
    --no-check-certificate \
    --header="Authorization: Bearer $AUTH_ENCODED" \
    --header="Accept: application/vnd.oci.image.manifest.v1+json" \
    "$MANIFEST_URL" 2>&1 | grep -E "HTTP/[0-9]\.[0-9] [0-9]{3}" | sed -E 's/.*HTTP\/[0-9]\.[0-9] ([0-9]{3}).*/\1/')

echo "HTTP_CODE: $HTTP_CODE"
echo "$HTTP_CODE" > http_code.txt
