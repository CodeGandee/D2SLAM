#!/bin/bash

# D2SLAM JetPack 6.2 Docker Management Script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "D2SLAM JetPack 6.2 Docker Management"
    echo "=============================================="
    echo -e "${NC}"
}

print_usage() {
    echo "Usage: $0 [COMMAND] [SERVICE]"
    echo ""
    echo "Commands:"
    echo "  build [SERVICE]     - Build service(s)"
    echo "  up [SERVICE]        - Start service(s)"
    echo "  down [SERVICE]      - Stop service(s)"
    echo "  exec SERVICE        - Execute bash in running service"
    echo "  logs [SERVICE]      - Show logs"
    echo "  status              - Show status of all services"
    echo "  clean               - Clean up containers and images"
    echo "  rebuild [SERVICE]   - Rebuild service from scratch"
    echo ""
    echo "Services:"
    echo "  d2slam-full         - Full build with TensorRT"
    echo "  d2slam-minimal      - Minimal build (recommended)"
    echo "  d2slam-dev          - Development build"
    echo "  all                 - All services (default)"
    echo ""
    echo "Examples:"
    echo "  $0 build d2slam-minimal"
    echo "  $0 up d2slam-dev"
    echo "  $0 exec d2slam-minimal"
    echo "  $0 rebuild all"
}

check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check if docker is installed
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        exit 1
    fi
    
    # Check if docker compose is available (try plugin first, then standalone)
    if docker compose version >/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="docker compose"
    elif command -v docker-compose >/dev/null 2>&1; then
        DOCKER_COMPOSE_CMD="docker-compose"
    else
        echo -e "${RED}Error: Docker Compose is not available${NC}"
        echo -e "${YELLOW}Please install Docker Compose or update Docker to include the compose plugin${NC}"
        exit 1
    fi
    
    # Check if nvidia runtime is available
    if ! docker info | grep -q nvidia >/dev/null 2>&1; then
        echo -e "${YELLOW}Warning: NVIDIA Docker runtime may not be available${NC}"
    fi
    
    echo -e "${GREEN}Prerequisites check passed (using: ${DOCKER_COMPOSE_CMD})${NC}"
}

build_service() {
    local service=$1
    echo -e "${BLUE}Building $service...${NC}"
    
    if [ "$service" = "all" ]; then
        $DOCKER_COMPOSE_CMD build
    else
        $DOCKER_COMPOSE_CMD build "$service"
    fi
    
    echo -e "${GREEN}Build completed for $service${NC}"
}

start_service() {
    local service=$1
    echo -e "${BLUE}Starting $service...${NC}"
    
    if [ "$service" = "all" ]; then
        $DOCKER_COMPOSE_CMD up -d
    else
        $DOCKER_COMPOSE_CMD up -d "$service"
    fi
    
    echo -e "${GREEN}Started $service${NC}"
}

stop_service() {
    local service=$1
    echo -e "${BLUE}Stopping $service...${NC}"
    
    if [ "$service" = "all" ]; then
        $DOCKER_COMPOSE_CMD down
    else
        $DOCKER_COMPOSE_CMD stop "$service"
    fi
    
    echo -e "${GREEN}Stopped $service${NC}"
}

exec_service() {
    local service=$1
    echo -e "${BLUE}Executing bash in $service...${NC}"
    $DOCKER_COMPOSE_CMD exec "$service" /bin/bash
}

show_logs() {
    local service=$1
    if [ -z "$service" ] || [ "$service" = "all" ]; then
        $DOCKER_COMPOSE_CMD logs -f
    else
        $DOCKER_COMPOSE_CMD logs -f "$service"
    fi
}

show_status() {
    echo -e "${BLUE}Service Status:${NC}"
    $DOCKER_COMPOSE_CMD ps
    echo ""
    echo -e "${BLUE}Images:${NC}"
    docker images | grep d2slam
}

clean_up() {
    echo -e "${YELLOW}Cleaning up containers and images...${NC}"
    read -p "This will remove all D2SLAM containers and images. Continue? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        $DOCKER_COMPOSE_CMD down --rmi all --volumes --remove-orphans
        docker system prune -f
        echo -e "${GREEN}Cleanup completed${NC}"
    else
        echo "Cleanup cancelled"
    fi
}

rebuild_service() {
    local service=$1
    echo -e "${BLUE}Rebuilding $service from scratch...${NC}"
    
    if [ "$service" = "all" ]; then
        $DOCKER_COMPOSE_CMD down
        $DOCKER_COMPOSE_CMD build --no-cache
        $DOCKER_COMPOSE_CMD up -d
    else
        $DOCKER_COMPOSE_CMD stop "$service"
        $DOCKER_COMPOSE_CMD build --no-cache "$service"
        $DOCKER_COMPOSE_CMD up -d "$service"
    fi
    
    echo -e "${GREEN}Rebuild completed for $service${NC}"
}

# Main script logic
print_header

# Check if no arguments provided
if [ $# -eq 0 ]; then
    print_usage
    exit 0
fi

# Check prerequisites
check_prerequisites

COMMAND=$1
SERVICE=${2:-all}

case $COMMAND in
    build)
        build_service "$SERVICE"
        ;;
    up|start)
        start_service "$SERVICE"
        ;;
    down|stop)
        stop_service "$SERVICE"
        ;;
    exec|bash)
        if [ "$SERVICE" = "all" ]; then
            echo -e "${RED}Error: Please specify a service for exec command${NC}"
            exit 1
        fi
        exec_service "$SERVICE"
        ;;
    logs)
        show_logs "$SERVICE"
        ;;
    status|ps)
        show_status
        ;;
    clean|cleanup)
        clean_up
        ;;
    rebuild)
        rebuild_service "$SERVICE"
        ;;
    help|--help|-h)
        print_usage
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$COMMAND'${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
