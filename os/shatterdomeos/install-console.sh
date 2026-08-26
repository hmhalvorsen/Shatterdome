#!/bin/bash
# ShatterdomeOS console mode — Ubuntu on PC or Raspberry Pi (arm64).
#
# Raspberry Pi: flash Ubuntu Server 24.04 for Raspberry Pi, then:
#   sudo SHATTERDOME_TGZ=Shatterdome-*-Linux-ARM64.tgz ./install-console.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then echo "Run as root: sudo $0"; exit 1; fi

SDOS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "${SDOS_DIR}/../.." && pwd)"
FILES_DIR="${SDOS_DIR}/files"
INSTALL_DIR="/opt/shatterdome"

. "${SDOS_DIR}/lib/detect-platform.sh"
. "${SDOS_DIR}/lib/branding.sh"
. "${SDOS_DIR}/lib/pi-setup.sh"

INSTALL_USER="$(default_console_user)"

echo "==> ShatterdomeOS console installer (Ubuntu)"
if is_raspberry_pi; then
  echo "    Platform: Raspberry Pi (arm64)"
else
  echo "    Platform: $(uname -m)"
fi

if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
  echo "Warning: this installer targets Ubuntu. Raspberry Pi OS (Debian) is not supported — use Ubuntu for Pi."
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  xserver-xorg-core xserver-xorg-input-all xserver-xorg-video-all \
  xinit x11-xserver-utils alsa-utils mesa-utils \
  libsdl2-2.0-0 libfreetype6 network-manager

if is_raspberry_pi; then
  configure_raspberry_pi_console "${INSTALL_USER}"
fi

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

if is_raspberry_pi; then
  HOSTNAME_TARGET="shatterdomeos-pi" apply_shatterdomeos_branding "${FILES_DIR}"
else
  HOSTNAME_TARGET="shatterdomeos-console" apply_shatterdomeos_branding "${FILES_DIR}"
fi

echo
echo "ShatterdomeOS console ready. Reboot to play."
echo "Machine ID: $(cat /etc/machine-id)"
echo "Config: /etc/shatterdome/consoles/<machine-id>.ini"
if is_raspberry_pi; then
  echo "Tip: set GPU memory to 128MB+ in firmware config if graphics are slow."
fi
