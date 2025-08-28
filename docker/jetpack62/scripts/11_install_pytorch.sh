#!/bin/bash

# PyTorch Installation Script for JetPack 6.2
# Installs PyTorch with multiple fallback options

set -e

echo "🔥 Installing PyTorch for JetPack 6.2..."

# Function to install from jetson-ai-lab
install_jetson_pytorch() {
    echo "📦 Trying PyTorch from jetson-ai-lab packages..."
    pip3 install --timeout=300 torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0 \
        --index-url https://elinux.org/jetson-packages/jp6/cu126
    return $?
}

# Function to install CUDA 12.1 wheels
install_cuda121_pytorch() {
    echo "📦 Trying PyTorch with CUDA 12.1 wheels..."
    pip3 install --timeout=300 torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/cu121
    return $?
}

# Function to install CPU-only version
install_cpu_pytorch() {
    echo "📦 Installing CPU-only PyTorch as fallback..."
    pip3 install --timeout=300 torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/cpu
    return $?
}

# Try installation methods in order
if install_jetson_pytorch; then
    echo "✅ PyTorch installed from jetson-ai-lab packages"
elif install_cuda121_pytorch; then
    echo "✅ PyTorch installed with CUDA 12.1 wheels"
elif install_cpu_pytorch; then
    echo "⚠️ PyTorch installed in CPU-only mode"
    echo "   CUDA functionality may be limited"
else
    echo "❌ Failed to install PyTorch with any method"
    exit 1
fi

echo "🔍 Verifying PyTorch installation..."

# Verify installation
python3 -c "import torch; print(f'PyTorch version: {torch.__version__}')"
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

echo "✅ PyTorch installation completed"
