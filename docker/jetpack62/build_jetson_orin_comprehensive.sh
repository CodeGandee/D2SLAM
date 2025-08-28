#!/bin/bash

# Comprehensive build script for Jetson Orin Docker images
set -e

echo "D2SLAM Docker Build Script for Jetson Orin (JetPack 6.2)"
echo "========================================================"

# Function to build with error handling
build_image() {
    local dockerfile=$1
    local image_name=$2
    local description=$3
    
    echo ""
    echo "Building ${description}..."
    echo "Dockerfile: ${dockerfile}"
    echo "Image name: ${image_name}"
    echo "Started at: $(date)"
    
    if docker build \
        --tag ${image_name} \
        --file ${dockerfile} \
        --progress=plain \
        . 2>&1 | tee "build_${image_name//[:\/]/_}.log"; then
        
        echo "✅ SUCCESS: ${description} built successfully!"
        docker images ${image_name}
        return 0
    else
        echo "❌ FAILED: ${description} build failed"
        echo "Check build_${image_name//[:\/]/_}.log for details"
        return 1
    fi
}

cd /workspace/D2SLAM/docker

echo "Available build options:"
echo "1. Full build with TensorRT (recommended for production)"
echo "2. Minimal build without TensorRT (faster, for development)"
echo "3. Try both (full first, minimal as fallback)"

read -p "Choose option (1-3) [default: 3]: " choice
choice=${choice:-3}

case $choice in
    1)
        echo "Building full version with TensorRT..."
        build_image "Dockerfile.jetson_orin_base_36.4.0" "d2slam:jetson-orin-36.4.0" "Full D2SLAM with TensorRT"
        ;;
    2)
        echo "Building minimal version..."
        build_image "Dockerfile.jetson_orin_base_36.4.0_minimal" "d2slam:jetson-orin-36.4.0-minimal" "Minimal D2SLAM"
        ;;
    3)
        echo "Trying full build first, minimal as fallback..."
        if ! build_image "Dockerfile.jetson_orin_base_36.4.0" "d2slam:jetson-orin-36.4.0" "Full D2SLAM with TensorRT"; then
            echo ""
            echo "Full build failed, trying minimal build as fallback..."
            build_image "Dockerfile.jetson_orin_base_36.4.0_minimal" "d2slam:jetson-orin-36.4.0-minimal" "Minimal D2SLAM"
        fi
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Build completed at: $(date)"
echo ""
echo "Available images:"
docker images | grep d2slam

echo ""
echo "Usage examples:"
echo "# Run full version:"
echo "docker run -it --runtime nvidia --rm d2slam:jetson-orin-36.4.0 /bin/bash"
echo ""
echo "# Run minimal version:"
echo "docker run -it --runtime nvidia --rm d2slam:jetson-orin-36.4.0-minimal /bin/bash"
echo ""
echo "# Mount workspace for development:"
echo "docker run -it --runtime nvidia --rm -v /workspace/D2SLAM:/root/swarm_ws/src/D2SLAM d2slam:jetson-orin-36.4.0-minimal /bin/bash"
