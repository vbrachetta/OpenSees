# Author: Chris Becker (goabonga: https://github.com/goabonga)
# Date: 11 Jul 2025
# GitHub Issue Link: https://github.com/OpenSees/OpenSees/issues/1633

# Description:
# This script installs OpenSees v.3.7.1 and it was tested on Debian GNU/Linux 12 Bookworm and Ubuntu 24.04.

# Usage:
# chmod +x install.sh
# ./install.sh

#!/bin/bash
set -e

VERSION="v3.7.1"
TAG="${VERSION}"
FOLDER="OpenSees-${VERSION#v}"
ZIP_URL="https://github.com/OpenSees/OpenSees/archive/refs/tags/${TAG}.zip"
ZIP_FILE="OpenSees-${TAG}.zip"
SRC_DIR="${FOLDER}"
BUILD_DIR="build-opensees"
PREFIX="/usr/local"

# --prefix argument (optional)
for arg in "$@"; do
  case $arg in
    --prefix=*)
      PREFIX="${arg#*=}"
      shift
      ;;
  esac
done

echo "📦 Installing dependencies..."

sudo apt update
sudo apt install -y \
  build-essential cmake g++ make unzip wget \
  libx11-dev libxmu-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev \
  libhdf5-dev libtcl8.6 \
  libopenblas-dev libgfortran5 \
  libssl-dev libcurl4-openssl-dev libzstd-dev zlib1g-dev libnghttp2-dev \
  libidn2-dev librtmp-dev libssh2-1-dev libpsl-dev \
  libkrb5-dev libldap2-dev libsasl2-dev libbrotli-dev \
  libaec-dev libgnutls28-dev libunistring-dev libp11-kit-dev \
  libtasn1-6-dev libkeyutils-dev libffi-dev gfortran tcl-dev tk-dev \
  libeigen3-dev \
  python3-dev python3

echo "📥 Downloading OpenSees $TAG..."
wget -O "$ZIP_FILE" "$ZIP_URL"

echo "📂 Unzipping..."
unzip "$ZIP_FILE"
rm "$ZIP_FILE"

cd "$SRC_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "🛠️ Configuring with CMake..."
cmake ..\
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-I/usr/include/tcl8.6 -I/usr/include/eigen3"

echo "🔧 Compiling..."
make -j"$(nproc)"

echo "🔧 Patch directories"
sudo mkdir -p /usr/include/lib/tcl8.6
sudo ln -s /usr/share/tcltk/tcl8.6/init.tcl /usr/include/lib/tcl8.6/init.tcl

echo "🚀 Installing to $PREFIX..."
sudo make install

echo "✅ OpenSees $TAG installed successfully in $PREFIX"
