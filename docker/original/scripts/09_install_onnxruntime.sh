#!/bin/bash
set -e

echo "Installing ONNXRuntime v${ONNX_VERSION} with CUDA and TensorRT..."

# Build ONNXRuntime from source
git clone -b v${ONNX_VERSION} --single-branch --recursive https://github.com/Microsoft/onnxruntime && \
cd onnxruntime && \
./build.sh --config Release --build_shared_lib --parallel \
    --use_cuda --cudnn_home /usr/ --cuda_home /usr/local/cuda --skip_test \
    --use_tensorrt --tensorrt_home /usr/ && \
cd build/Linux/Release && \
make install && \
rm -rf ../../../onnxruntime

# Install Python wheel for ONNXRuntime GPU
apt install python3-pip libopenblas-dev vim -y && \
wget https://nvidia.box.com/shared/static/v59xkrnvederwewo2f1jtv6yurl92xso.whl -O onnxruntime_gpu-1.12.1-cp38-cp38-linux_aarch64.whl && \
pip3 install onnxruntime_gpu-1.12.1-cp38-cp38-linux_aarch64.whl && \
rm onnxruntime_gpu-1.12.1-cp38-cp38-linux_aarch64.whl

echo "ONNXRuntime v${ONNX_VERSION} with CUDA and TensorRT installed successfully!"
