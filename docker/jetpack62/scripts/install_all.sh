#!/bin/bash

# Master Installation Script for JetPack 6.2
# Runs all dependency installation scripts in sequence

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting complete D2SLAM dependency installation for JetPack 6.2..."
echo "   This will install all dependencies in sequence"
echo "   Estimated time: 60-90 minutes"
echo ""

# List of scripts to run
SCRIPTS=(
    "00_setup_ssh.sh"
    "01_install_ros_dependencies.sh"
    "02_install_cmake.sh"
    "03_install_tensorrt.sh"
    "04_install_opencv_cuda.sh"
    "05_install_ceres_solver.sh"
    "06_install_lcm.sh"
    "07_install_faiss.sh"
    "08_install_opengv.sh"
    "09_install_backward_cpp.sh"
    "10_install_onnxruntime.sh"
    "11_install_pytorch.sh"
    "12_install_taichislam_deps.sh"
    "13_install_spdlog.sh"
    "14_build_d2slam.sh"
)

# Function to run a script with error handling
run_script() {
    local script=$1
    local script_path="${SCRIPT_DIR}/${script}"
    
    if [ ! -f "$script_path" ]; then
        echo "❌ Script not found: $script_path"
        return 1
    fi
    
    echo ""
    echo "========================================="
    echo "🔄 Running: $script"
    echo "========================================="
    
    if bash "$script_path"; then
        echo "✅ Completed: $script"
    else
        echo "❌ Failed: $script"
        return 1
    fi
}

# Run all scripts
start_time=$(date +%s)
failed_scripts=()

for script in "${SCRIPTS[@]}"; do
    if ! run_script "$script"; then
        failed_scripts+=("$script")
        echo "⚠️ Continuing with remaining scripts..."
    fi
done

end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo ""
echo "========================================="
echo "🏁 Installation Summary"
echo "========================================="
echo "⏱️ Total time: ${minutes}m ${seconds}s"

if [ ${#failed_scripts[@]} -eq 0 ]; then
    echo "✅ All scripts completed successfully!"
    echo ""
    echo "🎉 D2SLAM environment is ready for JetPack 6.2"
    echo "   You can now build and run D2SLAM applications"
else
    echo "⚠️ Some scripts failed:"
    for script in "${failed_scripts[@]}"; do
        echo "   ❌ $script"
    done
    echo ""
    echo "🔧 You may need to run the failed scripts manually"
fi

echo ""
echo "🔗 Next steps:"
echo "   1. Source ROS environment: source /opt/ros/noetic/setup.bash"
echo "   2. Source workspace: source /root/swarm_ws/devel/setup.bash"
echo "   3. Test D2SLAM build: cd /root/swarm_ws && catkin_make"
