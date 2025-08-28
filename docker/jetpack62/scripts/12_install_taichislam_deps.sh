#!/bin/bash

# TaichiSLAM Dependencies Installation Script for JetPack 6.2
# Installs Python packages and ROS components for TaichiSLAM

set -e

echo "🐍 Installing TaichiSLAM dependencies..."

echo "📦 Installing Python packages..."

# Install Python packages
pip install transformations numpy lcm matplotlib scipy

echo "📦 Installing ROS numpy package..."

# Install ROS numpy package
apt-get update
apt-get install -y ros-noetic-ros-numpy

echo "✅ TaichiSLAM dependencies installed successfully"
echo "   Python packages: transformations, numpy, lcm, matplotlib, scipy"
echo "   ROS packages: ros-noetic-ros-numpy"
