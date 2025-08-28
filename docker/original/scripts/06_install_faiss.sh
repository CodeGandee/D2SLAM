#!/bin/bash
set -e

echo "Installing Faiss v${FAISS_VERSION}..."

git clone -b v${FAISS_VERSION} --single-branch https://github.com/facebookresearch/faiss.git && \
cd faiss && \
cmake -B build -DCMAKE_BUILD_TYPE=Release -DFAISS_ENABLE_PYTHON=OFF -DFAISS_OPT_LEVEL=NEON -DBUILD_TESTING=OFF -DFAISS_ENABLE_GPU=OFF . && \
make -C build -j$(nproc) faiss && \
make -C build install && \
rm -rf ../faiss

echo "Faiss v${FAISS_VERSION} installed successfully!"
