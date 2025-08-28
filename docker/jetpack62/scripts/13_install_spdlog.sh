#!/bin/bash

# spdlog Installation Script for JetPack 6.2
# Installs spdlog v1.12.0 for fast logging

set -e

echo "📝 Installing spdlog v1.12.0..."

echo "📥 Downloading spdlog..."

# Download spdlog
wget https://github.com/gabime/spdlog/archive/refs/tags/v1.12.0.tar.gz
tar -zxvf v1.12.0.tar.gz

echo "🔧 Configuring spdlog build..."

# Configure and build spdlog
cd spdlog-1.12.0
mkdir build && cd build
cmake ..

echo "🔨 Building spdlog..."

# Build spdlog
make -j$(nproc)

echo "📦 Installing spdlog..."

# Install spdlog
make install

# Update library cache
ldconfig

# Cleanup
cd ../..
rm -rf spdlog-1.12.0 v1.12.0.tar.gz

echo "✅ spdlog installed successfully"
echo "   Version: 1.12.0"
echo "   Build type: Default"
