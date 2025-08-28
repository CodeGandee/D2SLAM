#!/bin/bash
set -e

echo "Installing PyTorch for Jetson..."

pip3 install --no-cache https://developer.download.nvidia.com/compute/redist/jp/v50/pytorch/torch-1.12.0a0+84d1cb9.nv22.4-cp38-cp38-linux_aarch64.whl

echo "PyTorch installed successfully!"
