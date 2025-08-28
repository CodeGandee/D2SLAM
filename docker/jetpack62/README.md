# D2SLAM Docker Setup for JetPack 6.2

This directory contains a comprehensive Docker environment for running D2SLAM on NVIDIA Jetson Orin with JetPack 6.2, following the same modular architecture as the original Jetson setup.

## 🏗️ Architecture Overview

### Modular Components

#### Shell Scripts (`scripts/`)
The installation process has been broken down into individual shell scripts:

1. **`00_setup_ssh.sh`** - SSH server configuration for remote development
2. **`01_install_ros_dependencies.sh`** - ROS Noetic and core dependencies (Ubuntu 20.04 focal)
3. **`02_install_cmake.sh`** - CMake 3.24.1 installation
4. **`03_install_tensorrt.sh`** - TensorRT for JetPack 6.2 (multiple installation methods)
5. **`04_install_opencv_cuda.sh`** - OpenCV 4.10.0 with CUDA support
6. **`05_install_ceres_solver.sh`** - Ceres Solver (D2SLAM branch)
7. **`06_install_lcm.sh`** - LCM v1.4.0
8. **`07_install_faiss.sh`** - Faiss v1.7.4 with NEON optimization
9. **`08_install_opengv.sh`** - OpenGV library
10. **`09_install_backward_cpp.sh`** - Backward-cpp for stack traces
11. **`10_install_onnxruntime.sh`** - ONNXRuntime 1.18.0 with CUDA/TensorRT
12. **`11_install_pytorch.sh`** - PyTorch for JetPack 6.2 (multiple fallback options)
13. **`12_install_taichislam_deps.sh`** - TaichiSLAM dependencies
14. **`13_install_spdlog.sh`** - spdlog v1.12.0
15. **`14_build_d2slam.sh`** - D2SLAM workspace build
16. **`install_all.sh`** - Master script to run all installations

#### Modular Dockerfiles
- `Dockerfile.jetson_orin_base_36.4.0_modular` - Base image with scripts (runtime installation)
- `Dockerfile.jetson_orin_base_36.4.0_build_time` - Base image with dependencies built at build time
- `Dockerfile.jetson_full_build_time` - Complete D2SLAM container with everything built
- `Dockerfile.jetson_orin_base_36.4.0` - Original monolithic Dockerfile (legacy compatibility)
- `Dockerfile.jetson_orin_base_36.4.0_minimal` - Original minimal Dockerfile (legacy compatibility)

## 🚀 Quick Start

### Using Docker Compose (Recommended)

The setup provides multiple profiles for different use cases:

#### Development Profile (Runtime Installation)
```bash
# Build and run development container
./manage.sh build development
./manage.sh run d2slam-dev

# Open shell and install dependencies at runtime
./manage.sh shell
./manage.sh install-deps

# Build D2SLAM
./manage.sh build-d2slam
```

#### Build-time Profile (Pre-installed Dependencies)
```bash
# Build container with dependencies pre-installed
./manage.sh build build-time
./manage.sh run d2slam-base-build-time

# Dependencies are already installed, just build D2SLAM
./manage.sh shell
./manage.sh build-d2slam
```

#### Full-build Profile (Everything Pre-built)
```bash
# Build complete container with D2SLAM ready to use
./manage.sh build full-build
./manage.sh run d2slam-full-build-time

# Everything is ready to use
./manage.sh shell
```

#### Legacy Profile (Original Dockerfiles)
```bash
# Use original monolithic Dockerfiles
./manage.sh build legacy
./manage.sh run d2slam-legacy-full
```

### Direct Docker Compose Commands

```bash
# Development
docker compose --profile development build
docker compose --profile development up d2slam-dev

# Build-time
docker compose --profile build-time build
docker compose --profile build-time up d2slam-base-build-time

# Full-build
docker compose --profile full-build build
docker compose --profile full-build up d2slam-full-build-time

# Legacy
docker compose --profile legacy build
docker compose --profile legacy up d2slam-legacy-full
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and modify as needed:

```bash
cp .env.example .env
```

Key configuration options:
- `SSH_PASSWORD`: SSH password for containers (default: d2slam123)
- `SSH_PORT`: SSH port mapping (default: 2222)
- `CUDA_ARCH_BIN`: CUDA architecture for Jetson Orin (default: 8.7)
- `USE_PROC`: Build parallelism (default: 8)

### SSH Access

All containers include SSH server for remote development:

```bash
# Show SSH connection info
./manage.sh ssh-info

# SSH into running container
./manage.sh ssh

# Or manually
ssh -p 2222 root@localhost
```

## 📋 Available Services

| Service | Profile | Description | Installation Method |
|---------|---------|-------------|-------------------|
| `d2slam-dev` | development | Development container | Manual runtime |
| `d2slam-base-runtime` | runtime | Base runtime container | Manual runtime |
| `d2slam-base-build-time` | build-time | Base with pre-installed deps | Automatic build-time |
| `d2slam-full-build-time` | full-build | Complete D2SLAM setup | Automatic build-time |
| `d2slam-legacy-full` | legacy | Original full build | Automatic build-time |
| `d2slam-legacy-minimal` | legacy | Original minimal build | Manual runtime |

## 🛠️ Management Commands

The `manage.sh` script provides comprehensive container management:

```bash
# Build commands
./manage.sh build development     # Build development profile
./manage.sh build build-time      # Build with pre-installed dependencies
./manage.sh build full-build      # Build complete setup
./manage.sh build legacy          # Build legacy containers
./manage.sh build all             # Build all profiles

# Runtime commands
./manage.sh run d2slam-dev        # Run development container
./manage.sh shell                 # Open shell in container
./manage.sh stop                  # Stop all containers
./manage.sh logs                  # Show container logs

# Installation commands (for runtime containers)
./manage.sh install-deps          # Install all dependencies
./manage.sh build-d2slam          # Build D2SLAM workspace

# SSH commands
./manage.sh ssh                   # SSH into container
./manage.sh ssh-info              # Show SSH connection details

# Maintenance commands
./manage.sh clean                 # Remove containers and images
./manage.sh help                  # Show help
```

## 🔍 Validation

Validate your setup before building:

```bash
./validate.sh
```

This checks:
- Docker and Docker Compose installation
- Required files and scripts
- Environment configuration
- System requirements

## 🐛 Troubleshooting

### Common Issues

1. **TensorRT Installation Fails**
   - The setup tries multiple installation methods
   - If all fail, TensorRT will be mounted from host system

2. **PyTorch Installation Issues**
   - Multiple fallback options are provided
   - May fall back to CPU-only version if GPU packages unavailable

3. **Build Timeout**
   - Increase Docker build timeout: `DOCKER_BUILDKIT_PROGRESS=plain docker compose build`
   - Use fewer parallel jobs: Set `USE_PROC=4` in `.env`

4. **SSH Connection Refused**
   - Ensure container is running: `./manage.sh run d2slam-dev`
   - Check SSH port: `./manage.sh ssh-info`

### Manual Installation

For runtime containers, dependencies must be installed manually:

```bash
# Enter container
./manage.sh shell

# Install all dependencies
/opt/d2slam/scripts/install_all.sh

# Or install individually
/opt/d2slam/scripts/01_install_ros_dependencies.sh
/opt/d2slam/scripts/02_install_cmake.sh
# ... etc

# Build D2SLAM
/opt/d2slam/scripts/14_build_d2slam.sh
```

## 🔄 Migration from Original Setup

The new modular setup is fully compatible with the original approach:

1. **Legacy containers** still use original Dockerfiles
2. **Script-based approach** allows for flexible installation
3. **Same dependencies** with improved organization
4. **Enhanced SSH support** for better development experience

## 🏷️ Version Compatibility

- **JetPack**: 6.2 (Ubuntu 22.04 host)
- **Container OS**: Ubuntu 20.04 (for ROS Noetic compatibility)
- **CUDA**: 12.6 runtime
- **ROS**: Noetic (focal repository)
- **OpenCV**: 4.10.0 with CUDA support
- **PyTorch**: 2.8.0 (with CUDA 12.6 support)

## 📝 Notes

- Uses Ubuntu 20.04 base images for ROS Noetic compatibility
- TensorRT installation includes multiple fallback methods
- SSH server pre-configured for remote development
- All scripts are executable and well-documented
- Environment variables provide easy customization

## 🤝 Contributing

When adding new dependencies:

1. Create a new script in `scripts/` directory
2. Make it executable: `chmod +x scripts/new_script.sh`
3. Add it to `install_all.sh`
4. Update the documentation

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
