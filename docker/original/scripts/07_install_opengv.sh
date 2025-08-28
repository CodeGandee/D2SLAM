#!/bin/bash
set -e

echo "Installing OpenGV..."

git clone https://github.com/HKUST-Swarm/opengv && \
mkdir opengv/build && cd opengv/build && \
cmake .. && \
make -j$(nproc) && \
make install

echo "OpenGV installed successfully!"
