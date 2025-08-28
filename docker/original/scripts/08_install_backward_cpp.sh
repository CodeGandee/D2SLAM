#!/bin/bash
set -e

echo "Installing Backward-cpp..."

wget https://raw.githubusercontent.com/bombela/backward-cpp/master/backward.hpp -O /usr/local/include/backward.hpp

echo "Backward-cpp installed successfully!"
