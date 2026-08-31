#!/usr/bin/env bash
# Publish release assets with gh CLI (no Actions artifact storage).
set -euo pipefail

TAG="${RELEASE_TAG:?Set RELEASE_TAG (e.g. SD-2026.08.26)}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS_DIR="${ROOT}/release-assets"

mkdir -p "${ASSETS_DIR}"
cp "${ROOT}/build-arm64/Shatterdome-${TAG}-Linux-arm64.tgz" "${ASSETS_DIR}/"
cp "${ROOT}/build-amd64/Shatterdome-${TAG}-Linux-amd64.tgz" "${ASSETS_DIR}/"
cp "${ROOT}/build-win/Shatterdome-${TAG}-Windows-amd64.zip" "${ASSETS_DIR}/"

(
  cd "${ASSETS_DIR}"
  shasum -a 256 Shatterdome-* > SHA256SUMS.txt
  cat SHA256SUMS.txt
)

if ! gh release view "${TAG}" --repo hmhalvorsen/Shatterdome >/dev/null 2>&1; then
  gh release create "${TAG}" \
    --repo hmhalvorsen/Shatterdome \
    --title "Shatterdome ${TAG}" \
    --notes "Multi-platform release packages for Linux, Windows, and Raspberry Pi."
fi

gh release upload "${TAG}" \
  --repo hmhalvorsen/Shatterdome \
  --clobber \
  "${ASSETS_DIR}/Shatterdome-${TAG}-Linux-arm64.tgz" \
  "${ASSETS_DIR}/Shatterdome-${TAG}-Linux-amd64.tgz" \
  "${ASSETS_DIR}/Shatterdome-${TAG}-Windows-amd64.zip" \
  "${ASSETS_DIR}/SHA256SUMS.txt"

echo "Release published: https://github.com/hmhalvorsen/Shatterdome/releases/tag/${TAG}"
