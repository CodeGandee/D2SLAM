#!/bin/bash

# Validation Script for D2SLAM JetPack 6.2 Environment
# This script validates the Docker setup and container functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 D2SLAM JetPack 6.2 Environment Validation${NC}"
echo "=============================================="

# Function to check if command exists
check_command() {
    local cmd=$1
    local desc=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "✅ ${desc}: ${GREEN}Found${NC}"
        return 0
    else
        echo -e "❌ ${desc}: ${RED}Not found${NC}"
        return 1
    fi
}

# Function to check Docker version
check_docker_version() {
    echo -e "${YELLOW}🐳 Checking Docker setup...${NC}"
    
    if check_command docker "Docker"; then
        local docker_version=$(docker --version)
        echo -e "   Version: ${docker_version}"
        
        # Check Docker Compose
        if docker compose version &> /dev/null; then
            local compose_version=$(docker compose version)
            echo -e "   Compose: ${compose_version}"
        else
            echo -e "❌ Docker Compose: ${RED}Not available${NC}"
            return 1
        fi
        
        # Check NVIDIA runtime
        if docker info | grep -q nvidia; then
            echo -e "✅ NVIDIA Runtime: ${GREEN}Available${NC}"
        else
            echo -e "⚠️ NVIDIA Runtime: ${YELLOW}Not detected${NC}"
            echo -e "   Note: This is expected if running on non-NVIDIA hardware"
        fi
    else
        return 1
    fi
}

# Function to validate files
check_files() {
    echo -e "${YELLOW}📂 Checking required files...${NC}"
    
    local files=(
        "docker-compose.yml"
        "manage.sh"
        ".env.example"
        "scripts/install_all.sh"
        "Dockerfile.jetson_orin_base_36.4.0_modular"
        "Dockerfile.jetson_orin_base_36.4.0_build_time"
        "Dockerfile.jetson_full_build_time"
    )
    
    local missing_files=0
    
    for file in "${files[@]}"; do
        if [ -f "$SCRIPT_DIR/$file" ]; then
            echo -e "✅ ${file}: ${GREEN}Found${NC}"
        else
            echo -e "❌ ${file}: ${RED}Missing${NC}"
            missing_files=$((missing_files + 1))
        fi
    done
    
    return $missing_files
}

# Function to check scripts directory
check_scripts() {
    echo -e "${YELLOW}📝 Checking installation scripts...${NC}"
    
    local scripts=(
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
        "install_all.sh"
    )
    
    local missing_scripts=0
    
    for script in "${scripts[@]}"; do
        local script_path="$SCRIPT_DIR/scripts/$script"
        if [ -f "$script_path" ]; then
            if [ -x "$script_path" ]; then
                echo -e "✅ ${script}: ${GREEN}Found (executable)${NC}"
            else
                echo -e "⚠️ ${script}: ${YELLOW}Found (not executable)${NC}"
            fi
        else
            echo -e "❌ ${script}: ${RED}Missing${NC}"
            missing_scripts=$((missing_scripts + 1))
        fi
    done
    
    return $missing_scripts
}

# Function to validate environment
check_environment() {
    echo -e "${YELLOW}🌍 Checking environment configuration...${NC}"
    
    if [ -f "$SCRIPT_DIR/.env" ]; then
        echo -e "✅ .env file: ${GREEN}Found${NC}"
        source "$SCRIPT_DIR/.env"
        
        # Check key variables
        local vars=(
            "SSH_PASSWORD"
            "SSH_PORT"
            "CUDA_ARCH_BIN"
            "USE_PROC"
        )
        
        for var in "${vars[@]}"; do
            if [ -n "${!var}" ]; then
                echo -e "✅ ${var}: ${GREEN}${!var}${NC}"
            else
                echo -e "⚠️ ${var}: ${YELLOW}Not set${NC}"
            fi
        done
    else
        echo -e "⚠️ .env file: ${YELLOW}Not found${NC}"
        echo -e "   Copy .env.example to .env and configure as needed"
    fi
}

# Function to test Docker Compose syntax
test_compose_syntax() {
    echo -e "${YELLOW}🔧 Testing Docker Compose syntax...${NC}"
    
    cd "$SCRIPT_DIR"
    
    if docker compose config &> /dev/null; then
        echo -e "✅ Docker Compose syntax: ${GREEN}Valid${NC}"
        return 0
    else
        echo -e "❌ Docker Compose syntax: ${RED}Invalid${NC}"
        echo -e "   Run 'docker compose config' for details"
        return 1
    fi
}

# Function to check system requirements
check_system_requirements() {
    echo -e "${YELLOW}💻 Checking system requirements...${NC}"
    
    # Check available disk space
    local available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    echo -e "   Available disk space: ${available_space}GB"
    
    if [ "$available_space" -gt 20 ]; then
        echo -e "✅ Disk space: ${GREEN}Sufficient${NC}"
    else
        echo -e "⚠️ Disk space: ${YELLOW}Low (recommend >20GB)${NC}"
    fi
    
    # Check available memory
    local available_memory=$(free -g | awk 'NR==2{print $7}')
    echo -e "   Available memory: ${available_memory}GB"
    
    if [ "$available_memory" -gt 4 ]; then
        echo -e "✅ Memory: ${GREEN}Sufficient${NC}"
    else
        echo -e "⚠️ Memory: ${YELLOW}Low (recommend >4GB)${NC}"
    fi
}

# Function to provide recommendations
show_recommendations() {
    echo -e "${BLUE}📋 Recommendations${NC}"
    echo "=================="
    echo ""
    echo "1. Quick Start (Development):"
    echo "   ./manage.sh build development"
    echo "   ./manage.sh run d2slam-dev"
    echo "   ./manage.sh install-deps"
    echo ""
    echo "2. Production Setup (Pre-built):"
    echo "   ./manage.sh build full-build"
    echo "   ./manage.sh run d2slam-full-build-time"
    echo ""
    echo "3. SSH Access:"
    echo "   ./manage.sh ssh-info"
    echo "   ssh -p 2222 root@localhost"
    echo ""
    echo "4. Environment Configuration:"
    echo "   cp .env.example .env"
    echo "   # Edit .env as needed"
    echo ""
}

# Main validation
main() {
    local errors=0
    
    check_docker_version || errors=$((errors + 1))
    echo ""
    
    check_files || errors=$((errors + 1))
    echo ""
    
    check_scripts || errors=$((errors + 1))
    echo ""
    
    check_environment
    echo ""
    
    test_compose_syntax || errors=$((errors + 1))
    echo ""
    
    check_system_requirements
    echo ""
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}🎉 Validation completed successfully!${NC}"
        echo -e "${GREEN}   Environment is ready for D2SLAM JetPack 6.2${NC}"
    else
        echo -e "${RED}❌ Validation failed with $errors error(s)${NC}"
        echo -e "${RED}   Please fix the issues above before proceeding${NC}"
    fi
    
    echo ""
    show_recommendations
    
    return $errors
}

main "$@"
