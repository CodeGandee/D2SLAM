#!/bin/bash

# Quick Start Script for D2SLAM JetPack 6.2
set -e

echo "D2SLAM JetPack 6.2 Quick Start"
echo "==============================="

cd "$(dirname "$0")"

echo "1. Checking Docker and prerequisites..."
if docker compose version >/dev/null 2>&1; then
    echo "✓ Docker Compose (plugin) found"
elif command -v docker-compose >/dev/null 2>&1; then
    echo "✓ Docker Compose (standalone) found"
else
    echo "Error: Docker Compose not found. Please install Docker Compose."
    exit 1
fi

echo "2. Building minimal D2SLAM image (recommended for first time)..."
./manage.sh build d2slam-minimal

echo "3. Starting development container..."
./manage.sh up d2slam-dev

echo ""
echo "🎉 D2SLAM is ready!"
echo ""
echo "To enter the container:"
echo "  ./manage.sh exec d2slam-dev"
echo ""
echo "Inside the container, you can:"
echo "  1. Build D2SLAM: cd /root/swarm_ws && catkin build d2slam"
echo "  2. Use dev tools: /root/dev_tools/dev_menu.sh"
echo ""
echo "Other useful commands:"
echo "  ./manage.sh status        - Check container status"
echo "  ./manage.sh logs          - View logs"
echo "  ./manage.sh down          - Stop containers"
echo "  ./manage.sh help          - Show all commands"
