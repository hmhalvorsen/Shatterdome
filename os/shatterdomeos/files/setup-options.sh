#!/bin/bash
# Build ~/.shatterdome/options.ini for ShatterdomeOS consoles.
set -euo pipefail

CONF_DIR="${HOME}/.shatterdome"
CONSOLE_DIR="/etc/shatterdome/consoles"
STATION_FILE="/etc/shatterdome/station"
mkdir -p "${CONF_DIR}"

# 1) Single-line station file (easiest for demos): /etc/shatterdome/station
if [ -f "${STATION_FILE}" ]; then
  station="$(tr '[:upper:]' '[:lower:]' < "${STATION_FILE}" | tr -d '[:space:]')"
  cat > "${CONF_DIR}/options.ini" << EOT
demo_mode=1
station=${station}
mvp_mode=1
language=en
autoconnectship=solo
EOT
  echo "ShatterdomeOS: station=${station}"
# 2) Per-machine ini file (full control)
elif [ -f "${CONSOLE_DIR}/$(cat /etc/machine-id 2>/dev/null).ini" ]; then
  cp "${CONSOLE_DIR}/$(cat /etc/machine-id).ini" "${CONF_DIR}/options.ini"
elif [ -f "${CONSOLE_DIR}/default.ini" ]; then
  cp "${CONSOLE_DIR}/default.ini" "${CONF_DIR}/options.ini"
else
  cat > "${CONF_DIR}/options.ini" << EOT
demo_mode=1
station=helms
mvp_mode=1
language=en
autoconnectship=solo
EOT
fi

# Optional shared demo settings (server name, scenario hints)
if [ -f /etc/shatterdome/demo.conf ]; then
  grep -v '^#' /etc/shatterdome/demo.conf | grep -v '^$' >> "${CONF_DIR}/options.ini" || true
fi

if [ -f /etc/shatterdome/hardware.ini ]; then
  cp /etc/shatterdome/hardware.ini "${CONF_DIR}/hardware.ini"
fi
