#!/bin/bash
set -e

SCRIPTS_DIR="$(dirname "$0")"

echo "Starting D2SLAM installation process..."
echo "Scripts directory: $SCRIPTS_DIR"

# Make all scripts executable
chmod +x "$SCRIPTS_DIR"/*.sh

echo "Step 0/13: Setting up SSH server and user..."
"$SCRIPTS_DIR/00_setup_ssh.sh"

echo "Step 1/13: Installing ROS dependencies..."
"$SCRIPTS_DIR/01_install_ros_dependencies.sh"

echo "Step 2/13: Installing CMake..."
"$SCRIPTS_DIR/02_install_cmake.sh"

echo "Step 3/13: Installing OpenCV with CUDA..."
"$SCRIPTS_DIR/03_install_opencv_cuda.sh"

echo "Step 4/13: Installing Ceres Solver..."
"$SCRIPTS_DIR/04_install_ceres_solver.sh"

echo "Step 5/13: Installing LCM..."
"$SCRIPTS_DIR/05_install_lcm.sh"

echo "Step 6/13: Installing Faiss..."
"$SCRIPTS_DIR/06_install_faiss.sh"

echo "Step 7/13: Installing OpenGV..."
"$SCRIPTS_DIR/07_install_opengv.sh"

echo "Step 8/13: Installing Backward-cpp..."
"$SCRIPTS_DIR/08_install_backward_cpp.sh"

echo "Step 9/13: Installing ONNXRuntime..."
"$SCRIPTS_DIR/09_install_onnxruntime.sh"

echo "Step 10/13: Installing PyTorch..."
"$SCRIPTS_DIR/10_install_pytorch.sh"

echo "Step 11/13: Installing TaichiSLAM dependencies..."
"$SCRIPTS_DIR/11_install_taichislam_deps.sh"

echo "Step 12/13: Installing spdlog..."
"$SCRIPTS_DIR/12_install_spdlog.sh"

echo "All dependencies installed successfully!"
echo "SSH server configured and ready!"
echo "To build D2SLAM, run: $SCRIPTS_DIR/13_build_d2slam.sh"
