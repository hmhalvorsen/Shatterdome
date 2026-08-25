#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PATH="/opt/homebrew/bin:$PATH"
if [[ ! -f ../SeriousProton/CMakeLists.txt ]]; then
  echo "Error: clone SeriousProton next to Shatterdome"
  exit 1
fi
GENERATOR=()
command -v ninja >/dev/null && GENERATOR=(-G Ninja)
cmake -S . -B build "${GENERATOR[@]}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DSERIOUS_PROTON_DIR=../SeriousProton \
  -DCMAKE_PREFIX_PATH="$(brew --prefix sdl2 2>/dev/null || echo /opt/homebrew/opt/sdl2)"
cmake --build build -j "$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
echo "Compile check passed."
