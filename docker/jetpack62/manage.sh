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
    echo -e "${BLUE}D2SLAM JetPack 6.2 Docker Management Script${NC}"
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
    echo "  legacy               Original monolithic Dockerfiles"
    echo ""
    echo "Services:"
    echo "  d2slam-dev           Development container (default)"
    echo "  d2slam-base-runtime  Base runtime container"
    echo "  d2slam-base-build-time    Base build-time container"
    echo "  d2slam-full-build-time    Full build-time container"
    echo "  d2slam-legacy-full        Legacy full container"
    echo "  d2slam-legacy-minimal     Legacy minimal container"
    echo ""
    echo "Examples:"
    echo "  $0 build development    # Build development profile"
    echo "  $0 run d2slam-dev      # Run development container"
    echo "  $0 shell               # Open shell in default container"
    echo "  $0 install-deps        # Install dependencies at runtime"
    echo "  $0 build build-time    # Build with dependencies pre-installed"
    echo "  $0 ssh                 # SSH into running container"
    echo ""
    echo "Environment variables (set in .env file):"
    echo "  SSH_PASSWORD          SSH password for containers (default: d2slam123)"
    echo "  SSH_PORT              SSH port mapping (default: 2222)"
    echo "  CUDA_ARCH_BIN         CUDA architecture (default: 8.7)"
    echo "  USE_PROC              Build parallelism (default: 8)"
}

# Load environment variables
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

build_images() {
    local profile=${1:-$PROFILE}
    
    echo -e "${GREEN}Building Docker images for profile: ${profile}${NC}"
    
    cd "$SCRIPT_DIR"
    
    case $profile in
        development|runtime)
            docker compose --profile development build
            ;;
        build-time)
            docker compose --profile build-time build
            ;;
        full-build)
            # Build base first, then full
            docker compose --profile build-time build d2slam-base-build-time
            docker compose --profile full-build build
            ;;
        legacy)
            docker compose --profile legacy build
            ;;
        all)
            echo -e "${YELLOW}Building all profiles...${NC}"
            docker compose --profile development build
            docker compose --profile build-time build
            docker compose --profile full-build build
            docker compose --profile legacy build
            ;;
        *)
            echo -e "${RED}Unknown profile: $profile${NC}"
            echo "Available profiles: development, runtime, build-time, full-build, legacy, all"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Build completed for profile: ${profile}${NC}"
}

run_service() {
    local service=${1:-$SERVICE}
    
    echo -e "${GREEN}Starting service: ${service}${NC}"
    
    cd "$SCRIPT_DIR"
    
    # Determine profile based on service name
    local profile="development"
    case $service in
        *-build-time)
            profile="build-time"
            ;;
        *-full-build-time)
            profile="full-build"
            ;;
        *-legacy-*)
            profile="legacy"
            ;;
    esac
    
    docker compose --profile "$profile" up -d "$service"
    
    echo -e "${GREEN}Service started: ${service}${NC}"
    echo -e "${BLUE}Container name: d2slam-jetpack62-$(echo $service | sed 's/d2slam-//')${NC}"
}

open_shell() {
    local service=${1:-$SERVICE}
    local container_name="d2slam-jetpack62-$(echo $service | sed 's/d2slam-//')"
    
    echo -e "${GREEN}Opening shell in container: ${container_name}${NC}"
    
    if docker ps --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        docker exec -it "$container_name" /bin/bash
    else
        echo -e "${RED}Container not running: ${container_name}${NC}"
        echo "Start it first with: $0 run $service"
        exit 1
    fi
}

stop_containers() {
    echo -e "${YELLOW}Stopping all D2SLAM containers...${NC}"
    
    cd "$SCRIPT_DIR"
    docker compose --profile development down
    docker compose --profile build-time down
    docker compose --profile full-build down
    docker compose --profile legacy down
    
    echo -e "${GREEN}All containers stopped${NC}"
}

clean_all() {
    echo -e "${YELLOW}Cleaning all D2SLAM containers and images...${NC}"
    
    # Stop containers first
    stop_containers
    
    # Remove images
    echo -e "${YELLOW}Removing Docker images...${NC}"
    docker images | grep 'd2slam.*jetson-orin-36.4.0' | awk '{print $3}' | xargs -r docker rmi -f
    
    # Clean build cache
    docker builder prune -f
    
    echo -e "${GREEN}Cleanup completed${NC}"
}

show_logs() {
    local service=${1:-$SERVICE}
    local container_name="d2slam-jetpack62-$(echo $service | sed 's/d2slam-//')"
    
    echo -e "${GREEN}Showing logs for: ${container_name}${NC}"
    docker logs -f "$container_name"
}

install_dependencies() {
    local service=${1:-$SERVICE}
    local container_name="d2slam-jetpack62-$(echo $service | sed 's/d2slam-//')"
    
    echo -e "${GREEN}Installing dependencies in container: ${container_name}${NC}"
    
    if docker ps --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        docker exec -it "$container_name" /opt/d2slam/scripts/install_all.sh
    else
        echo -e "${RED}Container not running: ${container_name}${NC}"
        echo "Start it first with: $0 run $service"
        exit 1
    fi
}

build_d2slam() {
    local service=${1:-$SERVICE}
    local container_name="d2slam-jetpack62-$(echo $service | sed 's/d2slam-//')"
    
    echo -e "${GREEN}Building D2SLAM in container: ${container_name}${NC}"
    
    if docker ps --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        docker exec -it "$container_name" /opt/d2slam/scripts/14_build_d2slam.sh
    else
        echo -e "${RED}Container not running: ${container_name}${NC}"
        echo "Start it first with: $0 run $service"
        exit 1
    fi
}

ssh_into_container() {
    local service=${1:-$SERVICE}
    local ssh_port=${SSH_PORT:-2222}
    local ssh_password=${SSH_PASSWORD:-d2slam123}
    
    echo -e "${GREEN}SSH into container for service: ${service}${NC}"
    echo -e "${BLUE}Host: localhost${NC}"
    echo -e "${BLUE}Port: ${ssh_port}${NC}"
    echo -e "${BLUE}User: root${NC}"
    echo -e "${BLUE}Password: ${ssh_password}${NC}"
    echo ""
    
    ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@localhost
}

show_ssh_info() {
    local ssh_port=${SSH_PORT:-2222}
    local ssh_password=${SSH_PASSWORD:-d2slam123}
    
    echo -e "${BLUE}SSH Connection Information${NC}"
    echo "========================="
    echo "Host: localhost"
    echo "Port: $ssh_port"
    echo "User: root"
    echo "Password: $ssh_password"
    echo ""
    echo "SSH Command:"
    echo "ssh -p $ssh_port root@localhost"
    echo ""
    echo "SCP Command (upload):"
    echo "scp -P $ssh_port /local/file root@localhost:/remote/path"
    echo ""
    echo "SCP Command (download):"
    echo "scp -P $ssh_port root@localhost:/remote/file /local/path"
}

# Main command processing
case "${1:-help}" in
    build)
        build_images "$2"
        ;;
    run)
        run_service "$2"
        ;;
    shell)
        open_shell "$2"
        ;;
    stop)
        stop_containers
        ;;
    clean)
        clean_all
        ;;
    logs)
        show_logs "$2"
        ;;
    install-deps)
        install_dependencies "$2"
        ;;
    build-d2slam)
        build_d2slam "$2"
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
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        usage
        exit 1
        ;;
esac
