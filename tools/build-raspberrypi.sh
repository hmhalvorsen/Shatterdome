#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d ../SeriousProton ]; then
  echo "Error: clone SeriousProton next to Shatterdome:"
  echo "  git clone https://github.com/daid/SeriousProton.git ../SeriousProton"
  exit 1
fi

echo "Configuring Shatterdome for Raspberry Pi / Linux ARM64..."
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DSERIOUS_PROTON_DIR=../SeriousProton \
  -DCMAKE_INSTALL_PREFIX=/opt/shatterdome

echo "Building..."
cmake --build build

echo "Installing to dist/..."
cmake --install build --prefix dist

echo "Creating TGZ package..."
cmake --build build --target package

echo "Done. Use the TGZ in build/ with ShatterdomeOS on Raspberry Pi (arm64)."
