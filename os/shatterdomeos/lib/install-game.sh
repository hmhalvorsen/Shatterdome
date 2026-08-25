#!/bin/bash
set -euo pipefail
INSTALL_DIR="${INSTALL_DIR:-/opt/shatterdome}"
TGZ="${SHATTERDOME_TGZ:-}"
REPO_DIR="${REPO_DIR:?REPO_DIR required}"
mkdir -p "${INSTALL_DIR}/bin"
if [ -n "${TGZ}" ] && [ "${TGZ}" != "auto" ]; then
  TMP="$(mktemp -d)"
  tar -xzf "${TGZ}" -C "${TMP}"
  BIN="$(find "${TMP}" -name Shatterdome -type f | head -1)"
  [ -n "${BIN}" ] || { echo "No Shatterdome binary in ${TGZ}"; exit 1; }
  GAME_ROOT="$(dirname "${BIN}")"
  rm -rf "${INSTALL_DIR}"/*
  cp -a "${GAME_ROOT}/." "${INSTALL_DIR}/"
  install -m 755 "${BIN}" "${INSTALL_DIR}/bin/Shatterdome"
  rm -rf "${TMP}"
elif [ "${TGZ}" = "auto" ] || [ ! -x "${INSTALL_DIR}/bin/Shatterdome" ]; then
  apt-get install -y --no-install-recommends git cmake ninja-build g++ libsdl2-dev libfreetype6-dev
  BUILD_ROOT="/usr/local/src/shatterdome-build"
  mkdir -p "${BUILD_ROOT}"
  [ -d "${BUILD_ROOT}/SeriousProton" ] || git clone --depth 1 https://github.com/daid/SeriousProton.git "${BUILD_ROOT}/SeriousProton"
  [ -d "${BUILD_ROOT}/Shatterdome" ] || git clone --depth 1 https://github.com/hmhalvorsen/Shatterdome.git "${BUILD_ROOT}/Shatterdome"
  cmake -S "${BUILD_ROOT}/Shatterdome" -B "${BUILD_ROOT}/build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DSERIOUS_PROTON_DIR="${BUILD_ROOT}/SeriousProton"
  cmake --build "${BUILD_ROOT}/build"
  cmake --install "${BUILD_ROOT}/build" --prefix "${INSTALL_DIR}"
  [ -x "${INSTALL_DIR}/bin/Shatterdome" ] || install -m 755 "${BUILD_ROOT}/build/Shatterdome" "${INSTALL_DIR}/bin/Shatterdome"
fi
[ -x "${INSTALL_DIR}/bin/Shatterdome" ] || [ ! -x "${INSTALL_DIR}/Shatterdome" ] || install -m 755 "${INSTALL_DIR}/Shatterdome" "${INSTALL_DIR}/bin/Shatterdome"
[ -x "${INSTALL_DIR}/bin/Shatterdome" ] || { echo "Missing ${INSTALL_DIR}/bin/Shatterdome"; exit 1; }
