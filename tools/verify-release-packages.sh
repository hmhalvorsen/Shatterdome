#!/usr/bin/env bash
# Smoke-test release packages before publishing.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${RELEASE_TAG:?Set RELEASE_TAG (e.g. SD-2026.08.26)}"

WORK="${ROOT}/.release-verify"
rm -rf "${WORK}"
mkdir -p "${WORK}"

copy_if_missing() {
  local name="$1"
  local src="${ROOT}/${2}"
  if [[ -f "${WORK}/${name}" ]]; then
    return 0
  fi
  if [[ -f "${src}" ]]; then
    cp "${src}" "${WORK}/${name}"
    return 0
  fi
  echo "Error: missing ${name} (expected at ${src} or ${WORK}/${name})"
  exit 1
}

case "${1:-all}" in
  linux-amd64)
    copy_if_missing "Shatterdome-${TAG}-Linux-amd64.tgz" "build-amd64/Shatterdome-${TAG}-Linux-amd64.tgz"
    ;;
  linux-arm64)
    "${ROOT}/tools/ensure-docker.sh" arm64
    copy_if_missing "Shatterdome-${TAG}-Linux-arm64.tgz" "build-arm64/Shatterdome-${TAG}-Linux-arm64.tgz"
    ;;
  windows-amd64)
    copy_if_missing "Shatterdome-${TAG}-Windows-amd64.zip" "build-win/Shatterdome-${TAG}-Windows-amd64.zip"
    ;;
  all)
    copy_if_missing "Shatterdome-${TAG}-Linux-amd64.tgz" "build-amd64/Shatterdome-${TAG}-Linux-amd64.tgz"
    copy_if_missing "Shatterdome-${TAG}-Linux-arm64.tgz" "build-arm64/Shatterdome-${TAG}-Linux-arm64.tgz"
    copy_if_missing "Shatterdome-${TAG}-Windows-amd64.zip" "build-win/Shatterdome-${TAG}-Windows-amd64.zip"
    ;;
  *)
    echo "Usage: $0 [all|linux-amd64|linux-arm64|windows-amd64]"
    exit 1
    ;;
esac

verify_linux() {
  local tgz="$1"
  local platform="$2"
  local profile="$3"
  echo "==> Verifying ${tgz} (${platform})"
  "${ROOT}/tools/ensure-docker.sh" "${profile}"
  docker run --rm \
    --platform "${platform}" \
    -v "${WORK}:/packages:ro" \
    ubuntu:24.04 \
    bash -c "
      set -euo pipefail
      export DEBIAN_FRONTEND=noninteractive
      export SDL_VIDEODRIVER=dummy
      apt-get update -qq
      apt-get install -y apt-utils
      apt-get install -y --no-install-recommends binutils libsdl2-2.0-0 libfreetype6 libgl1 ca-certificates
      rm -rf /opt/shatterdome
      mkdir -p /opt/shatterdome
      tar -xzf /packages/${tgz} -C /opt/shatterdome --strip-components=1
      test -x /opt/shatterdome/bin/Shatterdome
      test -f /opt/shatterdome/share/shatterdome/scripts/scenario_10_empty.lua
      grep -a -F -q '/opt/shatterdome/share/shatterdome/resources/' /opt/shatterdome/bin/Shatterdome
      cd /opt/shatterdome
      timeout 20s ./bin/Shatterdome headless=scenario_10_empty.lua server_port=35666 >/tmp/shatterdome.log 2>&1 &
      pid=\$!
      sleep 5
      kill -0 \$pid
      grep -Fq 'headless mode detected' /tmp/shatterdome.log
      grep -Fq 'Launching headless scenario scenario_10_empty.lua' /tmp/shatterdome.log
      kill \$pid
      wait \$pid || true
    "
}

verify_windows() {
  local zip="$1"
  echo "==> Verifying ${zip}"
  "${ROOT}/tools/ensure-docker.sh" amd64
  docker run --rm \
    --platform linux/amd64 \
    -v "${WORK}:/packages:ro" \
    ubuntu:24.04 \
    bash -c "
      set -euo pipefail
      export DEBIAN_FRONTEND=noninteractive
      apt-get update -qq
      apt-get install -y unzip
      rm -rf /work && mkdir -p /work
      unzip -q /packages/${zip} -d /work
      test -f /work/Shatterdome/Shatterdome.exe
      test -f /work/Shatterdome/scripts/scenario_10_empty.lua
      test -d /work/Shatterdome/resources/gui
    "
}

if [[ "${1:-all}" == "all" || "${1:-all}" == "linux-amd64" ]]; then
  verify_linux "Shatterdome-${TAG}-Linux-amd64.tgz" "linux/amd64" "amd64"
fi

if [[ "${1:-all}" == "all" || "${1:-all}" == "linux-arm64" ]]; then
  verify_linux "Shatterdome-${TAG}-Linux-arm64.tgz" "linux/arm64" "arm64"
fi

if [[ "${1:-all}" == "all" || "${1:-all}" == "windows-amd64" ]]; then
  verify_windows "Shatterdome-${TAG}-Windows-amd64.zip"
fi

echo "==> All release package checks passed."
