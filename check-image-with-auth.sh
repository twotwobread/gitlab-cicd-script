#!/bin/bash

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

AUTH_ENCODED=$(echo "$CONFIG_JSON" | jq -r ".auths[\"$REGISTRY\"].auth" 2>/dev/null)

if [ "$AUTH_ENCODED" = "null" ] || [ -z "$AUTH_ENCODED" ]; then
    echo "No auth found for $REGISTRY"
    echo "Available registries:"
    echo "$CONFIG_JSON" | jq -r '.auths | keys[]' 2>/dev/null
    exit 1
fi

echo "Found auth for $REGISTRY"


AUTH_DECODED=$(echo "$AUTH_ENCODED" | base64 -d)
MANIFEST_URL="https://$REGISTRY/v2/$IMAGE_PATH/manifests/$TAG"

echo "Generated Manifest URL: $MANIFEST_URL"


HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    --user "$AUTH_DECODED" \
    --header "Accept: application/vnd.oci.image.manifest.v1+json" \
    "$MANIFEST_URL")

echo "HTTP_CODE: $HTTP_CODE"
echo "$HTTP_CODE" > http_code.txt
