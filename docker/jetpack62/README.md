# D2SLAM Docker Setup for JetPack 6.2

This directory contains Docker configurations for running D2SLAM on NVIDIA Jetson Orin with JetPack 6.2.

## Directory Structure

```
jetpack62/
├── docker-compose.yml                           # Docker Compose configuration
├── Dockerfile.jetson_orin_base_36.4.0          # Full build with TensorRT
├── Dockerfile.jetson_orin_base_36.4.0_minimal  # Minimal build for development
├── build_jetson_orin_36.4.0.sh                 # Simple build script
├── build_jetson_orin_comprehensive.sh          # Comprehensive build script
└── README.md                                    # This file
```

## Prerequisites

- NVIDIA Jetson Orin or Orin NX
- JetPack 6.2 installed on host system
- Docker with NVIDIA runtime support
- Docker Compose

## Available Services

### 1. d2slam-full
- **Image**: `d2slam:jetson-orin-36.4.0-full`
- **Description**: Full D2SLAM build with TensorRT support
- **Use case**: Production deployment with maximum performance

### 2. d2slam-minimal
- **Image**: `d2slam:jetson-orin-36.4.0-minimal`
- **Description**: Minimal D2SLAM build without TensorRT
- **Use case**: Development and testing (faster build)

### 3. d2slam-dev
- **Image**: `d2slam:jetson-orin-36.4.0-dev`
- **Description**: Development container with additional tools
- **Use case**: Development with mounted source code

## Quick Start

### Build and Run with Docker Compose

```bash
# Navigate to the jetpack62 directory
cd /workspace/D2SLAM/docker/jetpack62

# Build and run minimal version (recommended for first try)
docker compose up -d d2slam-minimal

# Enter the container
docker compose exec d2slam-minimal /bin/bash

# Build and run full version
docker compose up -d d2slam-full
docker compose exec d2slam-full /bin/bash

# Build and run development version
docker compose up -d d2slam-dev
docker compose exec d2slam-dev /bin/bash
```

### Build Only (without running)

```bash
# Build all services
docker compose build

# Build specific service
docker compose build d2slam-minimal
docker compose build d2slam-full
```

### Alternative Build Methods

```bash
# Use comprehensive build script (tries full, falls back to minimal)
./build_jetson_orin_comprehensive.sh

# Use simple build script
./build_jetson_orin_36.4.0.sh

# Manual build
docker build -f Dockerfile.jetson_orin_base_36.4.0_minimal -t d2slam:jetson-orin-36.4.0-minimal ..
```

## Container Features

### Mounted Volumes
- **Source Code**: `/workspace/D2SLAM` → `/root/swarm_ws/src/D2SLAM`
- **X11 Display**: `/tmp/.X11-unix` for GUI applications
- **Device Access**: `/dev` for camera and sensor access

### Environment Variables
- `NVIDIA_VISIBLE_DEVICES=all` - Access to all GPUs
- `NVIDIA_DRIVER_CAPABILITIES=all` - Full NVIDIA capabilities
- `DISPLAY` - X11 display forwarding

### Network
- `host` mode for direct access to host network interfaces

## Development Workflow

### 1. Start Development Container
```bash
docker compose up -d d2slam-dev
docker compose exec d2slam-dev /bin/bash
```

### 2. Build D2SLAM in Container
```bash
# Inside container
cd /root/swarm_ws
catkin build d2slam
source devel/setup.bash
```

### 3. Run D2SLAM
```bash
# Launch D2SLAM with your configuration
roslaunch d2slam d2slam.launch
```

## Troubleshooting

### Build Issues

1. **TensorRT Installation Fails**:
   ```bash
   # Use minimal build instead
   docker compose build d2slam-minimal
   ```

2. **Network Issues**:
   ```bash
   # Check internet connectivity
   ping google.com
   
   # Use alternative mirrors in Dockerfile
   ```

3. **Out of Memory**:
   ```bash
   # Reduce parallel jobs in Dockerfile
   # Change USE_PROC=8 to USE_PROC=4 or USE_PROC=2
   ```

### Runtime Issues

1. **NVIDIA Runtime Not Found**:
   ```bash
   # Install nvidia-docker2
   sudo apt install nvidia-docker2
   sudo systemctl restart docker
   ```

2. **Display Issues**:
   ```bash
   # Allow X11 forwarding
   xhost +local:docker
   ```

3. **Permission Issues**:
   ```bash
   # Run with privileged mode (already enabled in compose)
   ```

## Build Differences

### Full Build
- TensorRT support for optimized inference
- ONNX Runtime with TensorRT backend
- PyTorch with CUDA support
- Longer build time (~2-3 hours)

### Minimal Build
- No TensorRT (uses host system libraries)
- ONNX Runtime with CUDA only
- PyTorch CPU version (with CUDA fallback)
- Faster build time (~1-2 hours)

## Performance Notes

- **Full build**: Maximum inference performance for production
- **Minimal build**: Good for development, relies on host TensorRT
- **Memory usage**: ~2GB RAM during build, ~1GB runtime
- **Storage**: ~8GB for full image, ~6GB for minimal

## Support

For issues specific to this Docker setup, check:
1. Build logs in the jetpack62 directory
2. JetPack 6.2 compatibility
3. NVIDIA container runtime installation
4. Host system TensorRT libraries
