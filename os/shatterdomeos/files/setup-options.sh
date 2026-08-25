#!/bin/bash
set -euo pipefail
CONF_DIR="${HOME}/.shatterdome"
CONSOLE_DIR="/etc/shatterdome/consoles"
mkdir -p "${CONF_DIR}"

ID="$(cat /etc/machine-id 2>/dev/null || true)"
if [ -z "${ID}" ]; then
  ID="$(hostname)"
fi

if [ -f "${CONSOLE_DIR}/${ID}.ini" ]; then
  cp "${CONSOLE_DIR}/${ID}.ini" "${CONF_DIR}/options.ini"
elif [ -f "${CONSOLE_DIR}/default.ini" ]; then
  cp "${CONSOLE_DIR}/default.ini" "${CONF_DIR}/options.ini"
else
  cat > "${CONF_DIR}/options.ini" << EOT
instance_name=${ID}
mvp_mode=1
language=en
autoconnect=Helms
autoconnect_address=192.168.1.100
EOT
fi

if [ -f /etc/shatterdome/hardware.ini ]; then
  cp /etc/shatterdome/hardware.ini "${CONF_DIR}/hardware.ini"
fi
