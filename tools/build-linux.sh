#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

INSTALL_PREFIX="${INSTALL_PREFIX:-$ROOT/dist}"
INSTALL_DEPS="${INSTALL_DEPS:-0}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
DO_PACKAGE="${DO_PACKAGE:-1}"

if [[ ! -f ../SeriousProton/CMakeLists.txt ]]; then
  echo "Error: clone SeriousProton next to Shatterdome:"
  echo "  git clone https://github.com/daid/SeriousProton.git ../SeriousProton"
  exit 1
fi

if [[ "$INSTALL_DEPS" == "1" ]]; then
  if command -v apt-get >/dev/null; then
    echo "Installing build dependencies (apt)..."
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
      build-essential cmake ninja-build libsdl2-dev libfreetype6-dev
  else
    echo "Warning: INSTALL_DEPS=1 but apt-get not found; install deps manually."
  fi
fi

NPROC="$(nproc 2>/dev/null || echo 4)"
GENERATOR=()
if command -v ninja >/dev/null; then
  GENERATOR=(-G Ninja)
fi

ARCH="$(uname -m)"
echo "Configuring Shatterdome for Linux (${ARCH})..."

cmake -S . -B build "${GENERATOR[@]}" \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DSERIOUS_PROTON_DIR=../SeriousProton \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"

echo "Building..."
cmake --build build -j "$NPROC"

echo "Installing to ${INSTALL_PREFIX}..."
cmake --install build --prefix "$INSTALL_PREFIX"

if [[ "$DO_PACKAGE" == "1" ]]; then
  echo "Creating package..."
  cmake --build build --target package
  echo "Package: build/Shatterdome-*.tar.gz (or .tgz)"
fi

echo "Done."
echo "  Binary: ${INSTALL_PREFIX}/bin/Shatterdome"
echo "  Data:   ${INSTALL_PREFIX}/share/shatterdome/"
