#!/bin/bash

# ROS Dependencies Installation Script for JetPack 6.2
# Installs ROS Noetic and core dependencies on Ubuntu 20.04

set -e

echo "🤖 Installing ROS Noetic and core dependencies..."

export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Beijing

# Install basic dependencies
apt-get update
apt-get install -y tzdata

# Install essential packages
apt-get install -y wget curl lsb-release git \
    libatlas-base-dev \
    libeigen3-dev \
    libgoogle-glog-dev \
    libsuitesparse-dev \
    libglib2.0-dev \
    libyaml-cpp-dev \
    net-tools \
    htop \
    xterm \
    gdb \
    zip \
    unzip \
    libdw-dev \
    vim \
    xterm \
    software-properties-common \
    ca-certificates \
    gnupg

echo "📦 Setting up ROS repository..."

# Setup ROS repository (using focal for Ubuntu 20.04)
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# Update package list
apt-get update

echo "🤖 Installing ROS Noetic packages..."

# Install ROS Noetic packages
apt-get install -y --no-install-recommends \
    ros-noetic-ros-base \
    ros-noetic-nav-msgs \
    ros-noetic-sensor-msgs \
    ros-noetic-cv-bridge \
    ros-noetic-rviz \
    ros-noetic-image-transport-plugins \
    ros-noetic-pcl-ros \
    build-essential \
    ros-noetic-catkin \
    python3-catkin-tools \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential

echo "🔧 Initializing rosdep..."

# Initialize rosdep
rosdep init
rosdep update

echo "✅ ROS Noetic dependencies installed successfully"
echo "   Distribution: noetic"
echo "   Ubuntu: 20.04 (focal)"
echo "   Repository: http://packages.ros.org/ros/ubuntu focal main"
