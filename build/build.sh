#!/bin/bash

# Stop on errors
set -e

# Set Docker image name and image tag
DOCKER_IMAGE_NAME=${CI_REGISTRY_IMAGE}
DOCKER_IMAGE_TAG=${CI_APPLICATION_TAG}

# FIXME: echo image name & tag
echo "DOCKER_IMAGE_NAME: ${DOCKER_IMAGE_NAME}, DOCKER_IMAGE_TAG:${DOCKER_IMAGE_TAG}"

# Run Docker build
echo "Building Docker image..."
docker build --provenance=false -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .

# Log in to Docker registry
echo "Logging into Docker registry..."
docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

# Push Docker image
echo "Pushing Docker image to registry..."
docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

# Echo image tag
echo "Docker image pushed successfully: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
