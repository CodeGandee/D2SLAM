#!/bin/bash

# Ceres Solver Installation Script for JetPack 6.2
# Installs Ceres Solver from D2SLAM branch

set -e

echo "🧮 Installing Ceres Solver (D2SLAM branch)..."

CERES_VERSION=${CERES_VERSION:-2.1.0}

echo "📥 Cloning Ceres Solver from HKUST-Swarm..."

# Clone Ceres Solver from D2SLAM branch
git clone https://github.com/HKUST-Swarm/ceres-solver -b D2SLAM
cd ceres-solver

echo "🔧 Configuring Ceres Solver build..."

# Configure build
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_BENCHMARKS=OFF \
      -DCUDA=OFF \
      ..

echo "🔨 Building Ceres Solver..."

# Build and install
make -j$(nproc) install

# Update library cache
ldconfig

# Cleanup
cd ../../..
rm -rf ceres-solver

# Clean package cache
apt-get clean all

echo "✅ Ceres Solver installed successfully"
echo "   Branch: D2SLAM"
echo "   Build type: Release"
echo "   CUDA: disabled"
