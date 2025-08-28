#!/bin/bash
set -e

echo "Replacing CMake with version ${CMAKE_VERSION}..."

rm /usr/bin/cmake && \
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-aarch64.sh \
    -q -O /tmp/cmake-install.sh && \
chmod u+x /tmp/cmake-install.sh && \
/tmp/cmake-install.sh --skip-license --prefix=/usr/ && \
rm /tmp/cmake-install.sh && \
cmake --version

echo "CMake ${CMAKE_VERSION} installed successfully!"
