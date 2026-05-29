#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Starting Flutter Web Build on Vercel ==="

# 1. Clone Flutter SDK (stable branch, shallow clone to keep it fast)
echo "Downloading Flutter SDK..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "Flutter SDK directory already exists."
fi

# 2. Add Flutter binary to the environment PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Configure Flutter to enable web support
echo "Enabling Flutter Web support..."
flutter config --enable-web

# 4. Verify Flutter setup
echo "Verifying Flutter installation..."
flutter --version

# 5. Build Flutter Web application for release
echo "Building Flutter Web application (Release Mode)..."
flutter build web --release

echo "=== Build Completed Successfully! ==="
