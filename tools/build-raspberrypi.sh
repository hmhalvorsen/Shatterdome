#!/usr/bin/env bash
# Linux ARM64 build for Raspberry Pi (wraps build-linux.sh).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export INSTALL_PREFIX="${INSTALL_PREFIX:-dist}"
export DO_PACKAGE="${DO_PACKAGE:-1}"
echo "==> Raspberry Pi / Linux ARM64 build"
exec "${SCRIPT_DIR}/build-linux.sh"
