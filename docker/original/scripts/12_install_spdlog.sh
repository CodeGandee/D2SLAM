#!/bin/bash
set -e

echo "Installing spdlog v1.12.0..."

wget https://github.com/gabime/spdlog/archive/refs/tags/v1.12.0.tar.gz && \
tar -zxvf v1.12.0.tar.gz && \
cd spdlog-1.12.0 && \
mkdir build && cd build && \
cmake .. && \
make -j$(nproc) && \
make install

echo "spdlog v1.12.0 installed successfully!"
