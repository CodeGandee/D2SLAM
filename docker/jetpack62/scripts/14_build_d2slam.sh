#!/bin/bash

# D2SLAM Build Script for JetPack 6.2
# Builds the D2SLAM workspace using catkin

set -e

echo "🔨 Building D2SLAM workspace..."

# Set workspace environment
export SWARM_WS=${SWARM_WS:-/root/swarm_ws}

# Source ROS environment
source /opt/ros/noetic/setup.bash

echo "📁 Setting up workspace directory..."

# Create workspace if it doesn't exist
mkdir -p ${SWARM_WS}/src

echo "🔧 Configuring catkin workspace..."

# Navigate to workspace
cd ${SWARM_WS}

# Initialize catkin workspace if needed
if [ ! -f src/CMakeLists.txt ]; then
    catkin_init_workspace src
fi

echo "🔨 Building D2SLAM with catkin..."

# Build the workspace
catkin_make -j$(nproc)

echo "📝 Setting up environment..."

# Source the workspace
echo "source ${SWARM_WS}/devel/setup.bash" >> ~/.bashrc

echo "✅ D2SLAM workspace built successfully"
echo "   Workspace: ${SWARM_WS}"
echo "   Build system: catkin"
echo "   Environment sourced in ~/.bashrc"
