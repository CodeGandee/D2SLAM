#!/bin/bash

# Faiss Installation Script for JetPack 6.2
# Installs Faiss v1.7.4 with NEON optimization

set -e

echo "🔍 Installing Faiss ${FAISS_VERSION:-1.7.4}..."

FAISS_VERSION=${FAISS_VERSION:-1.7.4}

echo "📥 Cloning Faiss repository..."

# Clone Faiss repository
git clone -b v${FAISS_VERSION} --single-branch https://github.com/facebookresearch/faiss.git
cd faiss

echo "🔧 Configuring Faiss build with NEON optimization..."

# Configure build with NEON optimization for ARM
cmake -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DFAISS_ENABLE_PYTHON=OFF \
      -DFAISS_OPT_LEVEL=NEON \
      -DBUILD_TESTING=OFF \
      -DFAISS_ENABLE_GPU=OFF \
      .

echo "🔨 Building Faiss..."

# Build Faiss
make -C build -j$(nproc) faiss

echo "📦 Installing Faiss..."

# Install Faiss
make -C build install

# Update library cache
ldconfig

# Cleanup
cd ..
rm -rf faiss

echo "✅ Faiss installed successfully"
echo "   Version: ${FAISS_VERSION}"
echo "   Optimization: NEON (ARM)"
echo "   GPU support: disabled"
echo "   Python bindings: disabled"
