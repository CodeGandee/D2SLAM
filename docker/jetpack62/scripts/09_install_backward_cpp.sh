#!/bin/bash

# Backward-cpp Installation Script for JetPack 6.2
# Installs backward-cpp for enhanced stack traces

set -e

echo "🔙 Installing Backward-cpp..."

echo "📥 Downloading backward.hpp..."

# Download backward.hpp header file
wget https://raw.githubusercontent.com/bombela/backward-cpp/master/backward.hpp \
     -O /usr/local/include/backward.hpp

echo "✅ Backward-cpp installed successfully"
echo "   Header location: /usr/local/include/backward.hpp"
echo "   Usage: Include backward.hpp in your C++ projects for enhanced stack traces"
