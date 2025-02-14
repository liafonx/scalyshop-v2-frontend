#!/bin/bash
set -e  # Stop on errors

echo "Building Docker image: ${CI_REGISTRY_IMAGE}:${CI_APPLICATION_TAG}"

docker build -t ${CI_REGISTRY_IMAGE}:${CI_APPLICATION_TAG} .

echo "Pushing Docker image to registry..."
docker push ${CI_REGISTRY_IMAGE}:${CI_APPLICATION_TAG}

echo "Docker image pushed successfully: ${CI_REGISTRY_IMAGE}:${CI_APPLICATION_TAG}"
