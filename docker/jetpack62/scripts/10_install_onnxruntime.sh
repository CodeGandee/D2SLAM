#!/bin/bash

# ONNXRuntime Installation Script for JetPack 6.2
# Builds ONNXRuntime with CUDA and optional TensorRT support

set -e

echo "🧠 Installing ONNXRuntime with CUDA support..."

# Install build dependencies
echo "📦 Installing build dependencies..."
apt-get update
apt-get install -y python3-pip libopenblas-dev vim python3-dev

# Install Python dependencies
pip3 install numpy cmake

echo "📥 Cloning ONNXRuntime repository..."

# Clone ONNXRuntime
git clone -b v1.18.0 --single-branch --recursive https://github.com/Microsoft/onnxruntime
cd onnxruntime

# Function to build with TensorRT
build_with_tensorrt() {
    echo "🚀 Attempting to build with TensorRT support..."
    ./build.sh --config Release --build_shared_lib --parallel \
        --use_cuda --cudnn_home /usr/lib/aarch64-linux-gnu --cuda_home /usr/local/cuda --skip_test \
        --use_tensorrt --tensorrt_home /usr
    return $?
}

# Function to build with CUDA only
build_with_cuda_only() {
    echo "🔧 Building with CUDA only (TensorRT not available)..."
    ./build.sh --config Release --build_shared_lib --parallel \
        --use_cuda --cudnn_home /usr/lib/aarch64-linux-gnu --cuda_home /usr/local/cuda --skip_test
    return $?
}

echo "🔨 Building ONNXRuntime..."

# Try TensorRT first, fallback to CUDA only
if build_with_tensorrt; then
    echo "✅ ONNXRuntime built with TensorRT support"
elif build_with_cuda_only; then
    echo "✅ ONNXRuntime built with CUDA support only"
else
    echo "❌ Failed to build ONNXRuntime"
    exit 1
fi

echo "📦 Installing ONNXRuntime..."

# Install ONNXRuntime
cd build/Linux/Release
make install

# Update library cache
ldconfig

# Cleanup
cd ../../..
rm -rf onnxruntime

echo "✅ ONNXRuntime installed successfully"
echo "   Version: 1.18.0"
echo "   CUDA support: enabled"
echo "   TensorRT support: conditional (depends on availability)"
