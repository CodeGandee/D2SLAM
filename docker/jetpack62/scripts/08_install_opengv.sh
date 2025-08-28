#!/bin/bash

# OpenGV Installation Script for JetPack 6.2
# Installs OpenGV library for geometric vision algorithms

set -e

echo "👁️ Installing OpenGV..."

echo "📥 Cloning OpenGV repository..."

# Clone OpenGV repository from HKUST-Swarm
git clone https://github.com/HKUST-Swarm/opengv

echo "🔧 Configuring OpenGV build..."

# Configure and build OpenGV
mkdir opengv/build
cd opengv/build
cmake ..

echo "🔨 Building OpenGV..."

# Build OpenGV
make -j$(nproc)

echo "📦 Installing OpenGV..."

# Install OpenGV
make install

# Update library cache
ldconfig

# Cleanup
cd ../..
rm -rf opengv

echo "✅ OpenGV installed successfully"
echo "   Repository: HKUST-Swarm/opengv"
echo "   Build type: Default"
