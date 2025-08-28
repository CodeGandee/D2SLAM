#!/bin/bash
set -e

echo "Installing Ceres Solver (D2SLAM branch)..."

git clone https://github.com/HKUST-Swarm/ceres-solver -b D2SLAM && \
cd ceres-solver && \
mkdir build && cd build && \
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DBUILD_BENCHMARKS=OFF -DCUDA=OFF .. && \
make -j$(nproc) install && \
rm -rf ../../ceres-solver && \
apt-get clean all

echo "Ceres Solver installed successfully!"
