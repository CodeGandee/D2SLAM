#!/bin/bash

# LCM Installation Script for JetPack 6.2
# Installs LCM v1.4.0 for inter-process communication

set -e

echo "📡 Installing LCM v1.4.0..."

echo "📥 Cloning LCM repository..."

# Clone LCM repository
git clone https://github.com/lcm-proj/lcm
cd lcm

# Checkout specific version
git checkout tags/v1.4.0

echo "🔧 Configuring LCM build..."

# Configure build
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_BENCHMARKS=OFF \
      ..

echo "🔨 Building LCM..."

# Build and install
make -j$(nproc) install

# Update library cache
ldconfig

# Cleanup
cd ../../..
rm -rf lcm

echo "✅ LCM installed successfully"
echo "   Version: 1.4.0"
echo "   Build type: Release"
