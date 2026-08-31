#!/usr/bin/env bash
# Build Shatterdome release packages inside Docker (self-hosted macOS runners).
set -euo pipefail

PLATFORM="${1:?Usage: $0 linux-amd64|linux-arm64|windows-amd64}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${RELEASE_TAG:?Set RELEASE_TAG (e.g. SD-2026.08.26)}"

VER="${TAG#SD-}"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VER"

if ! command -v docker >/dev/null; then
  echo "Error: docker is required on the self-hosted runner."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker daemon is not running. Run tools/ensure-docker.sh first."
  exit 1
fi

case "$PLATFORM" in
  linux-amd64)
    DOCKER_PLATFORM="linux/amd64"
    COLIMA_PROFILE="amd64"
    PACKAGE="Shatterdome-${TAG}-Linux-amd64"
    BUILD_SCRIPT="./tools/build-linux.sh"
    BUILD_DIR="build-amd64"
    ARTIFACT_EXT="tgz"
    APT_PACKAGES="build-essential cmake ninja-build libsdl2-dev libfreetype6-dev"
    BUILD_JOBS="${BUILD_JOBS:-2}"
    ;;
  linux-arm64)
    DOCKER_PLATFORM="linux/arm64"
    COLIMA_PROFILE="arm64"
    PACKAGE="Shatterdome-${TAG}-Linux-arm64"
    BUILD_SCRIPT="./tools/build-raspberrypi.sh"
    BUILD_DIR="build-arm64"
    ARTIFACT_EXT="tgz"
    APT_PACKAGES="build-essential cmake ninja-build libsdl2-dev libfreetype6-dev"
    BUILD_JOBS="${BUILD_JOBS:-4}"
    ;;
  windows-amd64)
    DOCKER_PLATFORM="linux/amd64"
    COLIMA_PROFILE="amd64"
    PACKAGE="Shatterdome-${TAG}-Windows-amd64"
    BUILD_SCRIPT="./tools/build-windows.sh"
    BUILD_DIR="build-win"
    ARTIFACT_EXT="zip"
    APT_PACKAGES="build-essential cmake ninja-build mingw-w64 p7zip-full"
    BUILD_JOBS="${BUILD_JOBS:-2}"
    ;;
  *)
    echo "Error: unknown platform '${PLATFORM}'"
    exit 1
    ;;
esac

echo "==> Building ${PACKAGE}.${ARTIFACT_EXT} (${DOCKER_PLATFORM}, colima ${COLIMA_PROFILE})"

"${ROOT}/tools/ensure-docker.sh" "${COLIMA_PROFILE}"

docker run --rm \
  --platform "${DOCKER_PLATFORM}" \
  -v "${ROOT}:/src" \
  -w /src \
  -e CPACK_PACKAGE_VERSION_MAJOR="${MAJOR}" \
  -e CPACK_PACKAGE_VERSION_MINOR="${MINOR}" \
  -e CPACK_PACKAGE_VERSION_PATCH="${PATCH}" \
  -e CPACK_PACKAGE_FILE_NAME="${PACKAGE}" \
  -e BUILD_DIR="${BUILD_DIR}" \
  -e BUILD_JOBS="${BUILD_JOBS}" \
  ubuntu:24.04 \
  bash -c "
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y apt-utils
    apt-get install -y --no-install-recommends git ca-certificates ${APT_PACKAGES}
    git config --global --add safe.directory '*'
    rm -rf /SeriousProton ${BUILD_DIR}
    git clone --depth 1 https://github.com/daid/SeriousProton.git /SeriousProton
    ln -sfn /SeriousProton ../SeriousProton
    chmod +x tools/*.sh
    ARCH=\$(uname -m)
    export SDL2_DIR=/usr/lib/\${ARCH}-linux-gnu/cmake/SDL2
    export NPROC=${BUILD_JOBS}
    ${BUILD_SCRIPT}
  "

ARTIFACT="${ROOT}/${BUILD_DIR}/${PACKAGE}.${ARTIFACT_EXT}"
if [[ ! -f "${ARTIFACT}" ]]; then
  echo "Error: expected artifact not found: ${ARTIFACT}"
  exit 1
fi

echo "==> Done: ${ARTIFACT}"
