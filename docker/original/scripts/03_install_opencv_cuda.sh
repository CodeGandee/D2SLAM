#!/bin/bash
set -e

echo "Installing OpenCV ${OPENCV_VERSION} with CUDA support..."

apt update && \
apt install libgtk2.0-dev -y && \
wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv.zip && \
unzip opencv.zip && \
rm opencv.zip && \
git clone https://github.com/opencv/opencv_contrib.git -b ${OPENCV_VERSION} && \
cd opencv-${OPENCV_VERSION} && \
mkdir build && cd build && \
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
    -D BUILD_LIST=calib3d,features2d,highgui,dnn,imgproc,imgcodecs,cudev,cudaoptflow,cudaimgproc,cudalegacy,cudaarithm,cudacodec,cudastereo,cudafeatures2d,xfeatures2d,tracking,stereo,aruco,videoio,ccalib && \
make -j$(nproc) && \
make install

echo "OpenCV ${OPENCV_VERSION} with CUDA installed successfully!"
