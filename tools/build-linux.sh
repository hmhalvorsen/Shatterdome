#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="${BUILD_DIR:-build}"
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

CMAKE_EXTRA=()
if [[ -n "${CPACK_PACKAGE_FILE_NAME:-}" ]]; then
  CMAKE_EXTRA+=(-DCPACK_PACKAGE_FILE_NAME="${CPACK_PACKAGE_FILE_NAME}")
fi
if [[ -n "${CPACK_PACKAGE_VERSION_MAJOR:-}" ]]; then
  CMAKE_EXTRA+=(
    -DCPACK_PACKAGE_VERSION_MAJOR="${CPACK_PACKAGE_VERSION_MAJOR}"
    -DCPACK_PACKAGE_VERSION_MINOR="${CPACK_PACKAGE_VERSION_MINOR}"
    -DCPACK_PACKAGE_VERSION_PATCH="${CPACK_PACKAGE_VERSION_PATCH}"
  )
fi

rename_package() {
  local expected_base="${CPACK_PACKAGE_FILE_NAME:-Shatterdome}"
  local dest=""
  if [[ "$DO_PACKAGE" != "1" ]]; then
    return 0
  fi
  case "$expected_base" in
    *Windows*) dest="${BUILD_DIR}/${expected_base}.zip" ;;
    *) dest="${BUILD_DIR}/${expected_base}.tgz" ;;
  esac
  [[ -f "$dest" ]] && return 0
  for candidate in \
    "${BUILD_DIR}/${expected_base}.tar.gz" \
    "${BUILD_DIR}/Shatterdome.tar.gz" \
    "${BUILD_DIR}/Shatterdome.tgz" \
    "${BUILD_DIR}/Shatterdome.zip"; do
    if [[ -f "$candidate" ]]; then
      mv "$candidate" "$dest"
      echo "Renamed package to ${dest}"
      return 0
    fi
  done
  echo "Warning: could not find CPack output to rename to ${dest}"
}

ARCH="$(uname -m)"
echo "Configuring Shatterdome for Linux (${ARCH})..."

cmake -S . -B "$BUILD_DIR" "${GENERATOR[@]}" \
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
  -DSERIOUS_PROTON_DIR=../SeriousProton \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  "${CMAKE_EXTRA[@]}"

echo "Building..."
cmake --build "$BUILD_DIR" -j "$NPROC"

echo "Installing to ${INSTALL_PREFIX}..."
cmake --install "$BUILD_DIR" --prefix "$INSTALL_PREFIX"

if [[ "$DO_PACKAGE" == "1" ]]; then
  echo "Creating package..."
  cmake --build "$BUILD_DIR" --target package
  rename_package
  echo "Package: ${BUILD_DIR}/${CPACK_PACKAGE_FILE_NAME:-Shatterdome}.tgz"
fi

echo "Done."
echo "  Binary: ${INSTALL_PREFIX}/bin/Shatterdome"
echo "  Data:   ${INSTALL_PREFIX}/share/shatterdome/"
