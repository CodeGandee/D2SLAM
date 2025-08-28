#!/bin/bash

# Development tools for D2SLAM container
echo "D2SLAM Development Tools"
echo "========================"

# Function to build D2SLAM
build_d2slam() {
    echo "Building D2SLAM..."
    cd /root/swarm_ws
    source /opt/ros/noetic/setup.bash
    catkin build d2slam -j$(nproc)
    source devel/setup.bash
    echo "D2SLAM build completed!"
}

# Function to run tests
run_tests() {
    echo "Running D2SLAM tests..."
    cd /root/swarm_ws
    source devel/setup.bash
    catkin test d2slam
}

# Function to check dependencies
check_deps() {
    echo "Checking dependencies..."
    echo "OpenCV version:"
    python3 -c "import cv2; print(cv2.__version__)"
    echo "PyTorch version:"
    python3 -c "import torch; print(torch.__version__)"
    echo "CUDA available:"
    python3 -c "import torch; print(torch.cuda.is_available())"
    echo "ROS version:"
    rosversion -d
}

# Function to monitor system resources
monitor_system() {
    echo "System monitoring..."
    echo "GPU status:"
    nvidia-smi
    echo "Memory usage:"
    free -h
    echo "CPU usage:"
    htop -n 1
}

# Function to clean build
clean_build() {
    echo "Cleaning build..."
    cd /root/swarm_ws
    catkin clean -y
    rm -rf build/ devel/
}

# Main menu
while true; do
    echo ""
    echo "Select an option:"
    echo "1. Build D2SLAM"
    echo "2. Run tests"
    echo "3. Check dependencies"
    echo "4. Monitor system"
    echo "5. Clean build"
    echo "6. Exit"
    
    read -p "Enter choice [1-6]: " choice
    
    case $choice in
        1) build_d2slam ;;
        2) run_tests ;;
        3) check_deps ;;
        4) monitor_system ;;
        5) clean_build ;;
        6) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
