#!/usr/bin/env bash
# Cross-compile Shatterdome for Windows (x86_64) from Linux using MinGW.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD_DIR="${BUILD_DIR:-build-win}"
INSTALL_PREFIX="${INSTALL_PREFIX:-$ROOT/dist-win}"
DO_PACKAGE="${DO_PACKAGE:-1}"

if [[ ! -f ../SeriousProton/CMakeLists.txt ]]; then
  echo "Error: clone SeriousProton next to Shatterdome:"
  echo "  git clone https://github.com/daid/SeriousProton.git ../SeriousProton"
  exit 1
fi

NPROC="$(nproc 2>/dev/null || echo 4)"
NPROC="${BUILD_JOBS:-${NPROC}}"
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

# LTO can crash MinGW under QEMU; keep a plain Release build for release packages.
CMAKE_EXTRA+=(
  -DCMAKE_CXX_FLAGS_RELEASE=-O3
  -DCMAKE_C_FLAGS_RELEASE=-O3
  -DCMAKE_EXE_LINKER_FLAGS_RELEASE=
)

rename_package() {
  local expected_base="${CPACK_PACKAGE_FILE_NAME:-Shatterdome}"
  local dest="${BUILD_DIR}/${expected_base}.zip"
  [[ -f "$dest" ]] && return 0
  for candidate in \
    "${BUILD_DIR}/${expected_base}.tar.gz" \
    "${BUILD_DIR}/Shatterdome.tar.gz" \
    "${BUILD_DIR}/Shatterdome.zip"; do
    if [[ -f "$candidate" ]]; then
      mv "$candidate" "$dest"
      echo "Renamed package to ${dest}"
      return 0
    fi
  done
  echo "Warning: could not find CPack output to rename to ${dest}"
}

echo "Configuring Shatterdome for Windows (MinGW x86_64)..."

cmake -S . -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/cmake/mingw.toolchain" \
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
  echo "Package: ${BUILD_DIR}/${CPACK_PACKAGE_FILE_NAME:-Shatterdome}.zip"
fi

echo "Done."
