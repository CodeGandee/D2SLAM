#!/bin/bash

# Validation script for D2SLAM JetPack 6.2 Docker setup
set -e

echo "🔍 D2SLAM JetPack 6.2 Setup Validation"
echo "======================================="

cd "$(dirname "$0")"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

validate_item() {
    local item=$1
    local command=$2
    local expected=$3
    
    echo -n "Checking $item... "
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Validate Docker setup
echo "🐳 Docker Setup:"
validate_item "Docker installed" "command -v docker"
validate_item "Docker Compose available" "docker compose version"
validate_item "Docker daemon running" "docker info"

echo ""
echo "📁 File Structure:"
validate_item "Docker Compose file" "test -f docker-compose.yml"
validate_item "Full Dockerfile" "test -f Dockerfile.jetson_orin_base_36.4.0"
validate_item "Minimal Dockerfile" "test -f Dockerfile.jetson_orin_base_36.4.0_minimal"
validate_item "Management script" "test -x manage.sh"
validate_item "Quickstart script" "test -x quickstart.sh"
validate_item "Environment file" "test -f .env"
validate_item "Development tools" "test -d dev_tools"

echo ""
echo "⚙️  Configuration:"
validate_item "Docker Compose syntax" "docker compose config"
validate_item "Environment variables" "test -s .env"

echo ""
echo "📋 Summary:"
echo "✅ All essential components are present"
echo "✅ Docker Compose configuration is valid"
echo "✅ Scripts are executable"

echo ""
echo "🚀 Ready to use! Try these commands:"
echo "  ./quickstart.sh           # Quick setup"
echo "  ./manage.sh help          # Show all commands"
echo "  ./manage.sh build d2slam-minimal  # Build minimal image"
echo "  ./manage.sh up d2slam-dev # Start development container"

echo ""
echo "📚 Documentation available in:"
echo "  README.md                 # Comprehensive guide"
echo "  SETUP_SUMMARY.md         # Quick overview"
