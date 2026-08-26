#!/bin/bash
# ShatterdomeOS demo server — boots headless scenario, consoles autoconnect via LAN.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then echo "Run as root: sudo $0"; exit 1; fi

SDOS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "${SDOS_DIR}/../.." && pwd)"
FILES_DIR="${SDOS_DIR}/files"
INSTALL_DIR="/opt/shatterdome"
SCENARIO="${DEMO_SCENARIO:-scenario_demo_bridge.lua}"
SERVER_NAME="${DEMO_SERVER_NAME:-EPSICON}"

. "${SDOS_DIR}/lib/detect-platform.sh"
. "${SDOS_DIR}/lib/branding.sh"
. "${SDOS_DIR}/lib/pi-setup.sh"

echo "==> ShatterdomeOS demo server installer (Ubuntu)"
is_raspberry_pi && echo "    Platform: Raspberry Pi (arm64)"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends libsdl2-2.0-0 libfreetype6 alsa-utils

is_raspberry_pi && configure_raspberry_pi_server

mkdir -p /etc/shatterdome "${INSTALL_DIR}/bin"
. "${SDOS_DIR}/lib/install-game.sh"

install -m 644 "${SDOS_DIR}/demo/server.ini" /etc/shatterdome/server.ini
sed -i "s/scenario_demo_bridge.lua/${SCENARIO}/; s/EPSICON/${SERVER_NAME}/" /etc/shatterdome/server.ini

cat > "${INSTALL_DIR}/bin/setup-server.sh" << 'EOS'
#!/bin/bash
mkdir -p /root/.shatterdome
cp /etc/shatterdome/server.ini /root/.shatterdome/options.ini
EOS
chmod +x "${INSTALL_DIR}/bin/setup-server.sh"

install -m 644 "${FILES_DIR}/shatterdome-server.service" /etc/systemd/system/shatterdome-server.service
systemctl daemon-reload
systemctl enable shatterdome-server.service

if is_raspberry_pi; then
  HOSTNAME_TARGET="shatterdomeos-pi-server" apply_shatterdomeos_branding "${FILES_DIR}"
else
  HOSTNAME_TARGET="shatterdomeos-server" apply_shatterdomeos_branding "${FILES_DIR}"
fi

echo "ShatterdomeOS demo server ready."
echo "  Scenario: ${SCENARIO}"
echo "  LAN name: ${SERVER_NAME}"
echo "  Start this machine FIRST, then boot the 5 consoles."
