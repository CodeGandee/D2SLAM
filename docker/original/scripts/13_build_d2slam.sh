#!/bin/bash
set -e

echo "Building D2SLAM..."

# Create workspace
mkdir -p ${SWARM_WS}/src/
cd ${SWARM_WS}/src/

# Clone dependencies
git clone https://github.com/HKUST-Swarm/swarm_msgs.git -b D2SLAM
git clone https://github.com/HKUST-Swarm/sync_bag_player.git
git clone https://github.com/ros-perception/vision_opencv.git -b ${ROS_VERSION}

# Source D2SLAM is copied via COPY command in Dockerfile
cd ${SWARM_WS}

# Set environment and build
export PATH=/usr/local/cuda/bin:$PATH
export CUDA_HOME=/usr/local/cuda
. /opt/ros/${ROS_VERSION}/setup.sh

catkin config -DCMAKE_BUILD_TYPE=Release \
    --cmake-args -DONNXRUNTIME_LIB_DIR=/usr/local/lib/ \
    -DONNXRUNTIME_INC_DIR=/usr/local/include/onnxruntime/core/session/ \
    -DTorch_DIR=/usr/local/lib/python3.8/dist-packages/torch/share/cmake/Torch

catkin build

echo "D2SLAM built successfully!"
