#!/bin/bash
set -e

echo "Installing ROS dependencies..."

# Add ROS repository
apt update && apt install -y curl gnupg2 lsb-release
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list

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
