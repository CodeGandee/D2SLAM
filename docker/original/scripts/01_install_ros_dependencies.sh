#!/bin/bash
set -e

echo "Installing ROS dependencies..."

apt update && \
apt install -y \
    libeigen3-dev \
    libyaml-cpp-dev \
    libpcl-dev \
    ros-${ROS_VERSION}-cv-bridge \
    ros-${ROS_VERSION}-eigen-conversions \
    ros-${ROS_VERSION}-tf \
    ros-${ROS_VERSION}-message-filters \
    ros-${ROS_VERSION}-image-transport \
    ros-${ROS_VERSION}-tf2-ros \
    ros-${ROS_VERSION}-tf2-eigen \
    ros-${ROS_VERSION}-camera-info-manager \
    ros-${ROS_VERSION}-pcl-ros \
    build-essential \
    ros-${ROS_VERSION}-catkin \
    python3-catkin-tools \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential

rosdep init && rosdep update

echo "ROS dependencies installed successfully!"
