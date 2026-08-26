#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f ../SeriousProton/CMakeLists.txt ]]; then
  echo "Error: clone SeriousProton next to Shatterdome"
  exit 1
fi

OS="$(uname -s)"
NPROC=4
CMAKE_EXTRA=()

case "$OS" in
  Linux)
    NPROC="$(nproc 2>/dev/null || echo 4)"
    ;;
  Darwin)
    export PATH="/opt/homebrew/bin:$PATH"
    NPROC="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
    if command -v brew >/dev/null; then
      CMAKE_EXTRA=(-DCMAKE_PREFIX_PATH="$(brew --prefix sdl2 2>/dev/null || echo /opt/homebrew/opt/sdl2)")
    fi
    ;;
  *)
    echo "Warning: untested OS ${OS}; continuing anyway."
    ;;
esac

GENERATOR=()
if command -v ninja >/dev/null; then
  GENERATOR=(-G Ninja)
fi

cmake -S . -B build "${GENERATOR[@]}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DSERIOUS_PROTON_DIR=../SeriousProton \
  "${CMAKE_EXTRA[@]}"

cmake --build build -j "$NPROC"
echo "Compile check passed (${OS})."
