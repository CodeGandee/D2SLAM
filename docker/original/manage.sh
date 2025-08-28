#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PROFILE="development"
SERVICE="d2slam-dev"

usage() {
    echo -e "${BLUE}D2SLAM Original Jetson Docker Management Script${NC}"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build [PROFILE]      Build Docker images"
    echo "  run [SERVICE]        Run a Docker service"
    echo "  shell [SERVICE]      Open shell in running container"
    echo "  stop                 Stop all running containers"
    echo "  clean                Remove containers and images"
    echo "  logs [SERVICE]       Show logs for a service"
    echo "  install-deps         Install dependencies at runtime"
    echo "  build-d2slam         Build D2SLAM at runtime"
    echo "  ssh [SERVICE]        SSH into a running container"
    echo "  ssh-info             Show SSH connection information"
    echo "  help                 Show this help message"
    echo ""
    echo "Profiles:"
    echo "  development          Runtime installation (default)"
    echo "  runtime              Same as development"
    echo "  build-time           Build-time installation"
    echo "  full-build           Complete build with D2SLAM"
    echo ""
    echo "Services:"
    echo "  d2slam-dev           Development container (default)"
    echo "  d2slam-base-runtime  Base runtime container"
    echo "  d2slam-base-build-time    Base build-time container"
    echo "  d2slam-full-build-time    Full build-time container"
    echo ""
    echo "Examples:"
    echo "  $0 build development    # Build development profile"
    echo "  $0 run d2slam-dev      # Run development container"
    echo "  $0 shell               # Open shell in default container"
    echo "  $0 install-deps        # Install dependencies at runtime"
    echo "  $0 ssh d2slam-dev      # SSH into development container"
    echo "  $0 ssh-info            # Show SSH connection details"
    echo ""
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_nvidia_runtime() {
    if ! docker info | grep -q nvidia; then
        log_warning "NVIDIA runtime not detected. GPU features may not work."
        log_info "To enable GPU support, install nvidia-docker2 and restart Docker daemon."
    else
        log_success "NVIDIA runtime detected."
    fi
}

build_images() {
    local profile=${1:-$PROFILE}
    
    log_info "Building Docker images with profile: $profile"
    cd "$SCRIPT_DIR"
    
    case $profile in
        development|runtime)
            docker compose --profile runtime build
            ;;
        build-time)
            docker compose --profile build-time build
            ;;
        full-build)
            docker compose --profile full-build build
            ;;
        *)
            log_error "Unknown profile: $profile"
            log_info "Available profiles: development, runtime, build-time, full-build"
            exit 1
            ;;
    esac
    
    log_success "Build completed successfully!"
}

run_service() {
    local service=${1:-$SERVICE}
    
    log_info "Running service: $service"
    cd "$SCRIPT_DIR"
    
    # Determine profile based on service
    local profile=""
    case $service in
        d2slam-dev|d2slam-base-runtime)
            profile="--profile runtime"
            ;;
        d2slam-base-build-time|d2slam-full-build-time)
            profile="--profile build-time"
            ;;
    esac
    
    docker compose $profile up -d $service
    log_success "Service $service is running"
    
    if [[ $service == "d2slam-dev" ]]; then
        log_info "To access the container, run: $0 shell $service"
        log_info "To install dependencies, run: $0 install-deps"
        log_info "To build D2SLAM, run: $0 build-d2slam"
    fi
}

open_shell() {
    local service=${1:-$SERVICE}
    
    log_info "Opening shell in service: $service"
    cd "$SCRIPT_DIR"
    
    if ! docker compose ps $service | grep -q "Up"; then
        log_warning "Service $service is not running. Starting it now..."
        run_service $service
        sleep 2
    fi
    
    docker compose exec $service /bin/bash
}

stop_services() {
    log_info "Stopping all running containers..."
    cd "$SCRIPT_DIR"
    docker compose down
    log_success "All containers stopped"
}

clean_containers() {
    log_info "Cleaning up containers and images..."
    cd "$SCRIPT_DIR"
    docker compose down --rmi all --volumes --remove-orphans
    log_success "Cleanup completed"
}

show_logs() {
    local service=${1:-$SERVICE}
    
    log_info "Showing logs for service: $service"
    cd "$SCRIPT_DIR"
    docker compose logs -f $service
}

install_dependencies() {
    log_info "Installing dependencies at runtime..."
    cd "$SCRIPT_DIR"
    
    if ! docker compose ps d2slam-dev | grep -q "Up"; then
        log_warning "Development container is not running. Starting it now..."
        run_service d2slam-dev
        sleep 2
    fi
    
    docker compose exec d2slam-dev /opt/d2slam/scripts/install_all.sh
    log_success "Dependencies installed successfully!"
}

build_d2slam() {
    log_info "Building D2SLAM at runtime..."
    cd "$SCRIPT_DIR"
    
    if ! docker compose ps d2slam-dev | grep -q "Up"; then
        log_warning "Development container is not running. Starting it now..."
        run_service d2slam-dev
        sleep 2
    fi
    
    docker compose exec d2slam-dev /opt/d2slam/scripts/13_build_d2slam.sh
    log_success "D2SLAM built successfully!"
}

ssh_into_container() {
    local service=${1:-$SERVICE}
    
    log_info "SSH into service: $service"
    cd "$SCRIPT_DIR"
    
    # Get SSH port based on service
    local ssh_port=""
    case $service in
        d2slam-base-build-time)
            ssh_port="2222"
            ;;
        d2slam-base-runtime)
            ssh_port="2223"
            ;;
        d2slam-full-build-time)
            ssh_port="2224"
            ;;
        d2slam-dev)
            ssh_port="2225"
            ;;
        *)
            log_error "Unknown service: $service"
            return 1
            ;;
    esac
    
    if ! docker compose ps $service | grep -q "Up"; then
        log_warning "Service $service is not running. Starting it now..."
        run_service $service
        sleep 5  # Give SSH service time to start
    fi
    
    # Get SSH credentials from environment or use defaults
    local ssh_user="${SSH_USERNAME:-me}"
    local ssh_pass="${SSH_PASSWORD:-123456}"
    
    log_info "SSH connection details:"
    log_info "  Host: localhost"
    log_info "  Port: $ssh_port"
    log_info "  User: $ssh_user"
    log_info "  Password: $ssh_pass"
    log_info ""
    log_info "Connecting via SSH..."
    
    # Use sshpass if available, otherwise prompt for password
    if command -v sshpass &> /dev/null; then
        sshpass -p "$ssh_pass" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$ssh_port" "$ssh_user@localhost"
    else
        log_warning "sshpass not found. You'll need to enter the password manually."
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$ssh_port" "$ssh_user@localhost"
    fi
}

show_ssh_info() {
    log_info "SSH Connection Information for all services:"
    echo ""
    echo "Service                 | SSH Port | Username | Password | Status"
    echo "------------------------|----------|----------|----------|--------"
    
    cd "$SCRIPT_DIR"
    local ssh_user="${SSH_USERNAME:-me}"
    local ssh_pass="${SSH_PASSWORD:-123456}"
    
    # Check each service
    services=("d2slam-base-build-time:2222" "d2slam-base-runtime:2223" "d2slam-full-build-time:2224" "d2slam-dev:2225")
    
    for service_port in "${services[@]}"; do
        IFS=':' read -r service port <<< "$service_port"
        if docker compose ps "$service" | grep -q "Up"; then
            status="Running"
        else
            status="Stopped"
        fi
        printf "%-23s | %-8s | %-8s | %-8s | %s\n" "$service" "$port" "$ssh_user" "$ssh_pass" "$status"
    done
    
    echo ""
    log_info "SSH Commands:"
    echo "  ssh -p 2222 $ssh_user@localhost  # d2slam-base-build-time"
    echo "  ssh -p 2223 $ssh_user@localhost  # d2slam-base-runtime"
    echo "  ssh -p 2224 $ssh_user@localhost  # d2slam-full-build-time"
    echo "  ssh -p 2225 $ssh_user@localhost  # d2slam-dev"
    echo ""
    log_info "Root SSH is also enabled:"
    echo "  ssh -p 2222 root@localhost       # (password: same as user)"
    echo ""
    log_info "X11 Forwarding enabled. Use -X flag:"
    echo "  ssh -X -p 2225 $ssh_user@localhost"
}

# Main script logic
case "${1:-help}" in
    build)
        check_nvidia_runtime
        build_images "$2"
        ;;
    run)
        check_nvidia_runtime
        run_service "$2"
        ;;
    shell)
        open_shell "$2"
        ;;
    stop)
        stop_services
        ;;
    clean)
        clean_containers
        ;;
    logs)
        show_logs "$2"
        ;;
    install-deps)
        install_dependencies
        ;;
    build-d2slam)
        build_d2slam
        ;;
    ssh)
        ssh_into_container "$2"
        ;;
    ssh-info)
        show_ssh_info
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        log_error "Unknown command: $1"
        usage
        exit 1
        ;;
esac
