#!/bin/bash

# Build script for Jetson Orin Docker image with better error handling
set -e

IMAGE_NAME="d2slam:jetson-orin-36.4.0"
DOCKERFILE="Dockerfile.jetson_orin_base_36.4.0"

echo "Building Docker image: ${IMAGE_NAME}"
echo "Using Dockerfile: ${DOCKERFILE}"
echo "Build started at: $(date)"

# Function to handle build failure
handle_failure() {
    echo "BUILD FAILED at $(date)"
    echo "Last 50 lines of build output:"
    tail -50 build.log
    echo ""
    echo "Common solutions:"
    echo "1. Check internet connectivity"
    echo "2. Try building with --no-cache flag"
    echo "3. Check if NVIDIA repositories are accessible"
    echo "4. Verify JetPack 6.2 compatibility"
    exit 1
}

# Set trap to handle failures
trap 'handle_failure' ERR

# Build the image with verbose output
echo "Starting Docker build..."
docker build \
    --tag ${IMAGE_NAME} \
    --file ${DOCKERFILE} \
    --progress=plain \
    . 2>&1 | tee build.log

echo "BUILD SUCCESSFUL at $(date)"
echo "Image ${IMAGE_NAME} built successfully!"

# Show image size
echo "Image details:"
docker images ${IMAGE_NAME}

echo ""
echo "To run the container:"
echo "docker run -it --runtime nvidia --rm ${IMAGE_NAME} /bin/bash"
