#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${BLUE}🔍 D2SLAM Original Jetson Docker Validation${NC}"
echo "================================================"

# Check if we're in the right directory
if [[ ! -f "$SCRIPT_DIR/docker-compose.yml" ]]; then
    log_error "docker-compose.yml not found. Are you in the original/ directory?"
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed"
    exit 1
else
    log_success "Docker is installed: $(docker --version)"
fi

# Check Docker Compose
if docker compose version &> /dev/null; then
    log_success "Docker Compose (plugin) is available: $(docker compose version)"
elif command -v docker-compose &> /dev/null; then
    log_warning "Using legacy docker-compose: $(docker-compose --version)"
    log_info "Consider upgrading to Docker Compose plugin"
else
    log_error "Docker Compose is not available"
    exit 1
fi

# Check NVIDIA runtime
if docker info 2>/dev/null | grep -q nvidia; then
    log_success "NVIDIA Docker runtime is available"
else
    log_warning "NVIDIA Docker runtime not detected"
    log_info "GPU features may not work. Install nvidia-docker2 if needed."
fi

# Check original files
echo ""
log_info "Checking original files..."
required_files=(
    "Dockerfile.jetson_orin_base_35.3.1"
    "Dockerfile.jetson"
    "Makefile"
)

for file in "${required_files[@]}"; do
    if [[ -f "$SCRIPT_DIR/$file" ]]; then
        log_success "✓ $file"
    else
        log_error "✗ $file (missing)"
    fi
done

# Check modular files
echo ""
log_info "Checking modular files..."
modular_files=(
    "Dockerfile.jetson_orin_base_35.3.1_modular"
    "Dockerfile.jetson_orin_base_35.3.1_build_time"
    "Dockerfile.jetson_modular"
    "Dockerfile.jetson_build_time"
    "docker-compose.yml"
    "manage.sh"
    "README.md"
)

for file in "${modular_files[@]}"; do
    if [[ -f "$SCRIPT_DIR/$file" ]]; then
        log_success "✓ $file"
    else
        log_error "✗ $file (missing)"
    fi
done

# Check scripts directory
echo ""
log_info "Checking installation scripts..."
script_files=(
    "scripts/00_setup_ssh.sh"
    "scripts/01_install_ros_dependencies.sh"
    "scripts/02_install_cmake.sh"
    "scripts/03_install_opencv_cuda.sh"
    "scripts/04_install_ceres_solver.sh"
    "scripts/05_install_lcm.sh"
    "scripts/06_install_faiss.sh"
    "scripts/07_install_opengv.sh"
    "scripts/08_install_backward_cpp.sh"
    "scripts/09_install_onnxruntime.sh"
    "scripts/10_install_pytorch.sh"
    "scripts/11_install_taichislam_deps.sh"
    "scripts/12_install_spdlog.sh"
    "scripts/13_build_d2slam.sh"
    "scripts/install_all.sh"
)

for file in "${script_files[@]}"; do
    if [[ -f "$SCRIPT_DIR/$file" ]]; then
        if [[ -x "$SCRIPT_DIR/$file" ]]; then
            log_success "✓ $file (executable)"
        else
            log_warning "⚠ $file (not executable)"
        fi
    else
        log_error "✗ $file (missing)"
    fi
done

# Test Docker Compose syntax
echo ""
log_info "Validating Docker Compose configuration..."
cd "$SCRIPT_DIR"
if docker compose config &> /dev/null; then
    log_success "Docker Compose configuration is valid"
else
    log_error "Docker Compose configuration has errors"
    docker compose config
fi

# Check for conflicting containers
echo ""
log_info "Checking for existing containers..."
existing_containers=$(docker ps -a --filter "name=original" --format "table {{.Names}}\t{{.Status}}" | tail -n +2)
if [[ -n "$existing_containers" ]]; then
    log_info "Found existing containers:"
    echo "$existing_containers"
else
    log_info "No conflicting containers found"
fi

echo ""
echo -e "${GREEN}🎉 Validation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Copy .env.example to .env and customize if needed"
echo "  2. Run: ./manage.sh build development"
echo "  3. Run: ./manage.sh run d2slam-dev"
echo "  4. Run: ./manage.sh shell (or ./manage.sh ssh d2slam-dev)"
echo ""
echo "SSH Access:"
echo "  - SSH will be available on port 2225 for d2slam-dev"
echo "  - Default credentials: me/123456 (configurable in .env)"
echo "  - Use: ./manage.sh ssh-info for all SSH details"
echo ""
echo "For help: ./manage.sh help"
