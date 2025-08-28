#!/bin/bash
set -e

echo "Installing TaichiSLAM dependencies..."

pip install transformations numpy lcm matplotlib scipy && \
apt install ros-${ROS_VERSION}-ros-numpy -y

echo "TaichiSLAM dependencies installed successfully!"
