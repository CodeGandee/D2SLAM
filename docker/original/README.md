# D2SLAM Original Jetson Docker Setup

This directory contains the reorganized and modularized version of the original Jetson Docker build scripts for D2SLAM. The original monolithic Dockerfiles have been broken down into modular shell scripts that can be executed either during build time or at runtime.

## 🏗️ Architecture Overview

### Original Files (Preserved)
- `Dockerfile.jetson_orin_base_35.3.1` - Original base image Dockerfile
- `Dockerfile.jetson` - Original D2SLAM build Dockerfile  
- `Makefile` - Original Makefile

### Modular Components

#### Shell Scripts (`scripts/`)
The original RUN commands have been extracted into individual shell scripts:

1. **`01_install_ros_dependencies.sh`** - ROS Noetic and core dependencies
2. **`02_install_cmake.sh`** - CMake 3.26.4 installation
3. **`03_install_opencv_cuda.sh`** - OpenCV 4.5.4 with CUDA support
4. **`04_install_ceres_solver.sh`** - Ceres Solver (D2SLAM branch)
5. **`05_install_lcm.sh`** - LCM v1.4.0
6. **`06_install_faiss.sh`** - Faiss v1.7.4 with NEON optimization
7. **`07_install_opengv.sh`** - OpenGV library
8. **`08_install_backward_cpp.sh`** - Backward-cpp for stack traces
9. **`09_install_onnxruntime.sh`** - ONNXRuntime 1.12.1 with CUDA/TensorRT
10. **`10_install_pytorch.sh`** - PyTorch for Jetson
11. **`11_install_taichislam_deps.sh`** - TaichiSLAM dependencies
12. **`12_install_spdlog.sh`** - spdlog v1.12.0
13. **`13_build_d2slam.sh`** - D2SLAM workspace build
14. **`install_all.sh`** - Master script to run all installations

#### Modular Dockerfiles
- `Dockerfile.jetson_orin_base_35.3.1_modular` - Base image with scripts (runtime installation)
- `Dockerfile.jetson_orin_base_35.3.1_build_time` - Base image with dependencies built at build time
- `Dockerfile.jetson_modular` - D2SLAM container with flexible build options
- `Dockerfile.jetson_build_time` - D2SLAM container with everything built at build time

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
./manage.sh build-d2slam
```

#### Build-Time Profile (All Dependencies Pre-built)
```bash
# Build with all dependencies included
./manage.sh build build-time
./manage.sh run d2slam-base-build-time
```

#### Full Build Profile (Complete D2SLAM Pre-built)
```bash
# Build complete D2SLAM image
./manage.sh build full-build
./manage.sh run d2slam-full-build-time
```

### Docker Compose Profiles

| Profile | Description | Use Case |
|---------|-------------|----------|
| `development` | Runtime installation, flexible | Development and debugging |
| `runtime` | Same as development | Alternative name |
| `build-time` | All dependencies pre-built | Production base images |
| `full-build` | Complete D2SLAM pre-built | Production deployment |

### Management Script Commands

```bash
./manage.sh build [PROFILE]      # Build Docker images
./manage.sh run [SERVICE]        # Run a Docker service  
./manage.sh shell [SERVICE]      # Open shell in container
./manage.sh stop                 # Stop all containers
./manage.sh clean                # Remove containers and images
./manage.sh logs [SERVICE]       # Show service logs
./manage.sh install-deps         # Install dependencies at runtime
./manage.sh build-d2slam         # Build D2SLAM at runtime
./manage.sh ssh [SERVICE]        # SSH into running container
./manage.sh ssh-info             # Show SSH connection information
./manage.sh help                 # Show help
```

## 🔐 SSH Access

All containers include a pre-configured SSH server with the following features:

### SSH Configuration
- **Default Username**: `me` (configurable via `SSH_USERNAME`)
- **Default Password**: `123456` (configurable via `SSH_PASSWORD`)
- **Root Access**: Enabled with same password
- **X11 Forwarding**: Enabled for GUI applications
- **SFTP Support**: Enabled for file transfers
- **Admin Rights**: SSH user has passwordless sudo access

### SSH Ports by Service
| Service | SSH Port | Purpose |
|---------|----------|---------|
| `d2slam-base-build-time` | 2222 | Base image with dependencies |
| `d2slam-base-runtime` | 2223 | Base image for runtime installation |
| `d2slam-full-build-time` | 2224 | Complete D2SLAM image |
| `d2slam-dev` | 2225 | Development container |

### SSH Usage Examples

```bash
# Quick SSH access via management script
./manage.sh ssh d2slam-dev

# Direct SSH commands
ssh -p 2225 me@localhost          # User access
ssh -p 2225 root@localhost        # Root access
ssh -X -p 2225 me@localhost       # With X11 forwarding

# SFTP access
sftp -P 2225 me@localhost

# Show all SSH connection details
./manage.sh ssh-info
```

### Customizing SSH Credentials

Create a `.env` file from the template:
```bash
cp .env.example .env
```

Edit `.env` to customize SSH settings:
```bash
SSH_USERNAME=your_username
SSH_PASSWORD=your_secure_password
```

Then rebuild the containers:
```bash
./manage.sh clean
./manage.sh build development
```

## 🔧 Runtime Installation Workflow

When using the development profile, you can install components selectively:

```bash
# Enter container
./manage.sh shell

# Install specific components
/opt/d2slam/scripts/01_install_ros_dependencies.sh
/opt/d2slam/scripts/02_install_cmake.sh
/opt/d2slam/scripts/03_install_opencv_cuda.sh
# ... install other components as needed

# Or install everything at once
/opt/d2slam/scripts/install_all.sh

# Build D2SLAM
/opt/d2slam/scripts/13_build_d2slam.sh
```

## 📋 Environment Variables

All environment variables from the original Dockerfiles are preserved:

```bash
# Build Versions
CMAKE_VERSION=3.26.4
OPENCV_VERSION=4.5.4  
FAISS_VERSION=1.7.4
ONNX_VERSION=1.12.1
ROS_VERSION=noetic
ENABLE_NEON=ON
CUDA_ARCH_BIN=8.7

# Workspace
SWARM_WS=/root/swarm_ws

# SSH Configuration (NEW)
SSH_USERNAME=me               # SSH username (default: me)
SSH_PASSWORD=123456          # SSH password (default: 123456)

# Display
DISPLAY=:10.0               # X11 display for GUI applications

# NVIDIA Runtime
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=all
```

## 🎯 Key Features

### ✅ Modular Installation
- Each dependency is in a separate script
- Install components individually or all at once
- Easy to debug individual installation steps

### ✅ Build-Time vs Runtime Choice
- **Build-Time**: All dependencies baked into image (faster startup, larger images)
- **Runtime**: Install dependencies when needed (smaller images, flexible development)

### ✅ Docker Compose Integration
- Multiple service definitions for different use cases
- Profile-based builds
- Volume mounts for development
- NVIDIA runtime support

### ✅ SSH Server Integration (NEW)
- Pre-configured SSH server in all containers
- Configurable username/password via Docker Compose args
- X11 forwarding for GUI applications
- SFTP support for file transfers
- Root and user access with admin privileges
- Automatic DISPLAY environment variable setup

### ✅ Development-Friendly
- Source code mounted as volume for live editing
- X11 forwarding for GUI applications
- Interactive shell access
- SSH access for remote development
- Comprehensive logging

## 🔍 Troubleshooting

### Common Issues

1. **NVIDIA Runtime Not Found**
   ```bash
   # Install nvidia-docker2
   sudo apt-get install nvidia-docker2
   sudo systemctl restart docker
   ```

2. **Permission Errors**
   ```bash
   # Fix script permissions
   chmod +x scripts/*.sh
   chmod +x manage.sh
   ```

3. **Build Failures**
   ```bash
   # Check logs
   ./manage.sh logs d2slam-dev
   
   # Try runtime installation instead
   ./manage.sh build development
   ./manage.sh shell
   /opt/d2slam/scripts/install_all.sh
   ```

### Validation

The installation scripts include validation steps. Check the output for:
- ✅ Successful installation messages
- Version confirmations
- Error messages with context

## 📊 Comparison with Original

| Aspect | Original | Modular |
|--------|----------|---------|
| **Maintainability** | Monolithic RUN commands | Individual scripts |
| **Debugging** | Hard to isolate failures | Easy component testing |
| **Flexibility** | Build-time only | Build-time + Runtime |
| **Development** | Rebuild entire image | Install/test components |
| **CI/CD** | Single build path | Multiple build strategies |

## 🔗 Integration

This modular setup can be used alongside the main Docker setup:

```bash
# Original jetpack62 setup (newer)
cd docker/jetpack62
./manage.sh build

# Original Jetson setup (this directory)  
cd docker/original
./manage.sh build development
```

Both setups are independent and can coexist in the same project.
