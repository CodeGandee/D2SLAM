#!/bin/bash

# CMake Installation Script for JetPack 6.2
# Installs CMake 3.24.1 for modern build support

set -e

echo "⚙️ Installing CMake 3.24.1..."

CMAKE_VERSION=${CMAKE_VERSION:-3.24.1}

# Remove old cmake
rm -f /usr/bin/cmake

echo "📥 Downloading CMake ${CMAKE_VERSION}..."

# Download and install CMake
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-aarch64.sh \
    -q -O /tmp/cmake-install.sh

chmod u+x /tmp/cmake-install.sh

echo "🔧 Installing CMake..."

# Install CMake
/tmp/cmake-install.sh --skip-license --prefix=/usr/

# Cleanup
rm /tmp/cmake-install.sh

# Verify installation
cmake_version=$(cmake --version | head -n1)
echo "✅ CMake installed successfully"
echo "   Version: ${cmake_version}"
