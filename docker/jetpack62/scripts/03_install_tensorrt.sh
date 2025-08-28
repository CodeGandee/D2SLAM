#!/bin/bash

# TensorRT Installation Script for JetPack 6.2
# Attempts multiple installation methods for TensorRT

set -e

echo "🚀 Installing TensorRT for JetPack 6.2..."

# Method 1: Try with CUDA keyring
install_tensorrt_cuda_keyring() {
    echo "📦 Trying TensorRT installation via CUDA keyring..."
    
    wget --timeout=30 --tries=3 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/sbsa/cuda-keyring_1.0-1_all.deb
    dpkg -i cuda-keyring_1.0-1_all.deb
    apt-get update
    
    apt-get install -y --no-install-recommends \
        libnvinfer10 libnvinfer-plugin10 libnvparsers10 libnvonnxparsers10 \
        libnvinfer-dev libnvinfer-plugin-dev libnvparsers-dev libnvonnxparsers-dev \
        python3-libnvinfer python3-libnvinfer-dev
    
    rm -f cuda-keyring_1.0-1_all.deb
    echo "✅ TensorRT installed successfully via CUDA keyring"
    return 0
}

# Method 2: Try alternative keyring approach
install_tensorrt_alternative() {
    echo "📦 Trying alternative TensorRT installation method..."
    
    wget --timeout=30 --tries=3 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/sbsa/cuda-ubuntu2004.pin
    mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
    
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/sbsa/3bf863cc.pub
    add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/sbsa/ /"
    
    apt-get update
    
    apt-get install -y --no-install-recommends \
        libnvinfer10 libnvinfer-plugin10 libnvparsers10 libnvonnxparsers10 \
        libnvinfer-dev libnvinfer-plugin-dev libnvparsers-dev libnvonnxparsers-dev \
        python3-libnvinfer python3-libnvinfer-dev
    
    echo "✅ TensorRT installed successfully via alternative method"
    return 0
}

# Try installation methods in order
if install_tensorrt_cuda_keyring; then
    exit 0
elif install_tensorrt_alternative; then
    exit 0
else
    echo "⚠️ Warning: TensorRT packages not available"
    echo "   Will rely on host system TensorRT when container is run"
    echo "   Make sure JetPack 6.2 is properly installed on the host"
fi

echo "✅ TensorRT setup completed"
