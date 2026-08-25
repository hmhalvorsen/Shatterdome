#!/bin/bash
# ShatterdomeOS console mode on Ubuntu: boot straight into the game client.
# Run on Ubuntu Server 24.04 (amd64 or arm64), including Raspberry Pi with Ubuntu.
#
#   sudo SHATTERDOME_TGZ=Shatterdome-*.tgz ./install-console.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then echo "Run as root: sudo $0"; exit 1; fi

SDOS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "${SDOS_DIR}/../.." && pwd)"
FILES_DIR="${SDOS_DIR}/files"
INSTALL_DIR="/opt/shatterdome"
INSTALL_USER="${SHATTERDOME_USER:-shatterdome}"

. "${SDOS_DIR}/lib/branding.sh"

echo "==> ShatterdomeOS console installer (Ubuntu)"

if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
  echo "Warning: this installer targets Ubuntu. Other Debian-based systems may work."
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  xserver-xorg-core xserver-xorg-input-all xserver-xorg-video-all \
  xinit x11-xserver-utils alsa-utils mesa-utils \
  libsdl2-2.0-0 libfreetype6 network-manager

if ! id "${INSTALL_USER}" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "${INSTALL_USER}"
fi

mkdir -p /etc/shatterdome/consoles "${INSTALL_DIR}/bin"
install -m 755 "${FILES_DIR}/setup-options.sh" "${INSTALL_DIR}/bin/setup-options.sh"
install -m 755 "${FILES_DIR}/start-console.sh" "${INSTALL_DIR}/bin/start-console.sh"
cp -n "${SDOS_DIR}/consoles/default.ini" /etc/shatterdome/consoles/default.ini 2>/dev/null || true

. "${SDOS_DIR}/lib/install-game.sh"

mkdir -p "/home/${INSTALL_USER}/.shatterdome"
chown -R "${INSTALL_USER}:${INSTALL_USER}" "/home/${INSTALL_USER}/.shatterdome"

systemctl disable gdm3.service 2>/dev/null || true
systemctl disable lightdm.service 2>/dev/null || true
systemctl disable sddm.service 2>/dev/null || true

sed "s/__SHATTERDOME_USER__/${INSTALL_USER}/g" \
  "${FILES_DIR}/shatterdome-console.service" > /etc/systemd/system/shatterdome.service
systemctl daemon-reload
systemctl enable shatterdome.service

mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/10-shatterdomeos.conf << 'EOX'
Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection
EOX

HOSTNAME_TARGET="shatterdomeos-console" apply_shatterdomeos_branding "${FILES_DIR}"

echo
echo "ShatterdomeOS console ready. Reboot to play."
echo "Machine ID: $(cat /etc/machine-id)"
echo "Config: /etc/shatterdome/consoles/<machine-id>.ini"
