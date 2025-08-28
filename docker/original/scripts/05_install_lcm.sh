#!/bin/bash
set -e

echo "Installing LCM v1.4.0..."

git clone https://github.com/lcm-proj/lcm && \
cd lcm && \
git checkout tags/v1.4.0 && \
mkdir build && cd build && \
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DBUILD_BENCHMARKS=OFF .. && \
make -j$(nproc) install

echo "LCM v1.4.0 installed successfully!"
