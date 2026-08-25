#!/bin/bash
# ShatterdomeOS server mode on Ubuntu: boot straight into headless game server.
#
#   sudo SHATTERDOME_TGZ=Shatterdome-*.tgz HEADLESS_SCENARIO=scenario_01_empty.lua ./install-server.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then echo "Run as root: sudo $0"; exit 1; fi

SDOS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "${SDOS_DIR}/../.." && pwd)"
FILES_DIR="${SDOS_DIR}/files"
INSTALL_DIR="/opt/shatterdome"
SCENARIO="${HEADLESS_SCENARIO:-scenario_01_empty.lua}"
SERVER_NAME="${HEADLESS_NAME:-Shatterdome Bridge}"
SERVER_PORT="${SERVER_PORT:-35666}"

. "${SDOS_DIR}/lib/branding.sh"

echo "==> ShatterdomeOS server installer (Ubuntu)"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends libsdl2-2.0-0 libfreetype6 alsa-utils

mkdir -p /etc/shatterdome "${INSTALL_DIR}/bin"
. "${SDOS_DIR}/lib/install-game.sh"

cat > /etc/shatterdome/server.ini << EOFINI
headless=${SCENARIO}
headless_name=${SERVER_NAME}
server_port=${SERVER_PORT}
language=en
EOFINI

cat > "${INSTALL_DIR}/bin/setup-server.sh" << 'EOS'
#!/bin/bash
mkdir -p /root/.shatterdome
cp /etc/shatterdome/server.ini /root/.shatterdome/options.ini
EOS
chmod +x "${INSTALL_DIR}/bin/setup-server.sh"

install -m 644 "${FILES_DIR}/shatterdome-server.service" /etc/systemd/system/shatterdome-server.service
systemctl daemon-reload
systemctl enable shatterdome-server.service

HOSTNAME_TARGET="shatterdomeos-server" apply_shatterdomeos_branding "${FILES_DIR}"

echo "ShatterdomeOS server ready. Reboot to host ${SCENARIO} on port ${SERVER_PORT}."
