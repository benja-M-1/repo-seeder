#!/bin/bash

# Configuration
SOURCE_IMAGE="${SOURCE_IMAGE:-golang}"
DESTINATION_REPOSITORY="${DESTINATION_REPOSITORY:-image-management-test-repo}"
NUMBER_OF_TAGS="${NUMBER_OF_TAGS:-80}"
DOCKER_CONFIG_PATH="${DOCKER_CONFIG_PATH:-/root}"

if [ -z "${DESTINATION_NAMESPACE}" ]; then
    echo "DESTINATION_NAMESPACE environment variable must be set with the namespace to push to"
    exit 1
fi

mkdir -p /root/.docker
cp ${DOCKER_CONFIG_PATH}/config.json /root/.docker/config.json
sed -i "s/credsStore/credStore/g" /root/.docker/config.json

# Check if crane is installed
if ! command -v crane &> /dev/null; then
    echo "crane is not installed. Please install it first."
    echo "You can install it using: go install github.com/google/go-containerregistry/cmd/crane@latest"
    exit 1
fi

# Get the list of tags and sort them by creation date (newest first)
echo "Fetching tags from ${SOURCE_IMAGE}..."
TAGS=$(crane ls ${SOURCE_IMAGE} | head -n ${NUMBER_OF_TAGS})

# Counter for progress
CURRENT=0
TOTAL=$(echo "${TAGS}" | wc -l)
timestamp=$(date +%s)

# Process each tag
echo "${TAGS}" | while read -r TAG; do
    CURRENT=$((CURRENT + 1))
    SOURCE_IMAGE_WITH_TAG="${SOURCE_IMAGE}:${TAG}"
    DESTINATION_IMAGE="${DESTINATION_NAMESPACE}/${DESTINATION_REPOSITORY}:${TAG}"
    
    echo "[${CURRENT}/${TOTAL}] Copying ${SOURCE_IMAGE_WITH_TAG} to ${DESTINATION_IMAGE}"
    
    # Copy the image
    if crane copy "${SOURCE_IMAGE_WITH_TAG}" "${DESTINATION_IMAGE}"; then
        echo "✅ Successfully copied ${TAG}"
    else
        echo "❌ Failed to copy ${TAG}"
    fi
done

echo "Image sync completed!"

