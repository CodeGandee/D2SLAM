#!/bin/bash

# OpenCV with CUDA Installation Script for JetPack 6.2
# Builds OpenCV 4.10.0 with CUDA and DNN support

set -e

echo "🎥 Installing OpenCV ${OPENCV_VERSION:-4.10.0} with CUDA support..."

OPENCV_VERSION=${OPENCV_VERSION:-4.10.0}
CUDA_ARCH_BIN=${CUDA_ARCH_BIN:-8.7}
ENABLE_NEON=${ENABLE_NEON:-ON}

# Install GTK development libraries
apt-get update
apt-get install -y libgtk2.0-dev

echo "📥 Downloading OpenCV ${OPENCV_VERSION}..."

# Download OpenCV source
wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip
unzip opencv.zip
rm opencv.zip

# Download OpenCV contrib modules
git clone https://github.com/opencv/opencv_contrib.git -b ${OPENCV_VERSION}

echo "🔧 Configuring OpenCV build with CUDA..."

# Configure OpenCV build
cd opencv-${OPENCV_VERSION}
mkdir build && cd build

cmake .. \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_CUDA=ON \
    -D WITH_CUDNN=ON \
    -D WITH_CUBLAS=ON \
    -D CUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
    -D CUDA_ARCH_PTX= \
    -D CUDA_FAST_MATH=ON \
    -D WITH_TBB=ON \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_opencv_java=OFF \
    -D BUILD_opencv_python=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_opencv_apps=OFF \
    -D ENABLE_NEON=${ENABLE_NEON} \
    -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
    -D WITH_EIGEN=ON \
    -D WITH_IPP=OFF \
    -D WITH_OPENCL=OFF \
    -D BUILD_LIST=calib3d,features2d,highgui,dnn,imgproc,imgcodecs,cudev,cudaoptflow,cudaimgproc,cudalegacy,cudaarithm,cudacodec,cudastereo,cudafeatures2d,xfeatures2d,tracking,stereo,aruco,videoio,ccalib

echo "🔨 Building OpenCV (this may take a while)..."

# Build OpenCV
make -j$(nproc)

echo "📦 Installing OpenCV..."

# Install OpenCV
make install

# Update library cache
ldconfig

# Cleanup
cd ../../..
rm -rf opencv-${OPENCV_VERSION} opencv_contrib

echo "✅ OpenCV installed successfully"
echo "   Version: ${OPENCV_VERSION}"
echo "   CUDA support: enabled"
echo "   CUDA architectures: ${CUDA_ARCH_BIN}"
echo "   NEON optimization: ${ENABLE_NEON}"
