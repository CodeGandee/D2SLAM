# Docker for $D^2$SLAM

Our Docker image includes: 

- ros-noetic 
- ceres-2.1.0 
- onnxruntime-gpu-1.12.1 
- libtorch-latest 
- LCM 
- faiss 
- OpenCV4 with CUDA 
- OpenGV 
- Backward 
- $D^2$SLAM

## 🚀 Quick Start for JetPack 6.2 (Recommended)

For **NVIDIA Jetson Orin with JetPack 6.2**, use the organized `jetpack62/` subdirectory:

```bash
cd jetpack62
./quickstart.sh           # Quick setup with Docker Compose
# OR
./manage.sh help          # Full management options
```

The `jetpack62/` directory provides:
- Docker Compose setup with multiple build options
- Comprehensive management scripts
- Development tools and validation
- Complete documentation

## Alternative Docker Setups

### Modular Jetson Setup (JetPack 5.x)

For **NVIDIA Jetson Orin with JetPack 5.x** or for modular development with runtime flexibility:

```bash
cd original
./validate.sh             # Validate setup
./manage.sh build development   # Build with runtime installation
./manage.sh run d2slam-dev      # Run development container
./manage.sh shell               # Enter container
./manage.sh install-deps        # Install dependencies at runtime
```

The `original/` directory provides:
- Modular shell scripts extracted from original Dockerfiles
- Build-time vs runtime installation options
- Docker Compose with multiple profiles
- Individual component installation capability

### Legacy Docker Builds

### Docker PC

To build the Docker image for PC, run the following command:

```
$ make amd64
```

### Docker for Jetson (Legacy)

**Note**: For JetPack 6.2, please use the `jetpack62/` subdirectory instead.

This Docker file can be built on a MacBook with Apple Silicon (M1 or M2), X86_64 PC with [qemu support](https://www.stereolabs.com/docs/docker/building-arm-container-on-x86/) or on Jetson. However, in our tests, building on Jetson is takes hours and building on Qemu is even more slow.

We highly recommend building the image on a MacBook Pro with M1/M2 Max. This is possibly the fastest way.

To build the Docker image for $D^2$ SLAM (legacy), run:

```
$ make jetson
```

# No-CUDA configuration

**Note**: For JetPack 6.2, use `jetpack62/` which includes both full and minimal builds.

Target arm64 (Dockerfile.arm64_ros1_noetic) and x86_no_cuda (Dockerfile.x86_no_cuda) provide non-cuda configuration for arm64 and X86-64 devices. Others will depends on CUDA.
D2VINS only has fully abaility when using CUDA, features will be unsupported without CUDA:

- Superpoint and NetVLAD. You can only work with LK optical tracking.
- Loop clousure and pose graph
- Multi-robot localization will be disabled without CUDA
- Depth generation


Basically, without CUDA, D2SLAM will become a mono/stereo/quad camera visual-inertial odometry (VIO).

### Build Base Container (Optional)

To build the __base__ image for $D^2$SLAM (which contains the environment for those who would like to modify it), run:
```
$ make jetson_base
```

Then, in __Dockerfile_jetson_D2SLAM__, change:

```
FROM xuhao1/d2slam:jetson_base_35.1.0
```


to your own image name:

```
FROM your-image-name/d2slam:jetson_base_35.1.0
```


This Docker image has been tested on Jetpack 5.0.2/35.1.0 with Xavier NX.
