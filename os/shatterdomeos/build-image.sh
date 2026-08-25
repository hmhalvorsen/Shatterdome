#!/bin/bash
# Build a ShatterdomeOS root filesystem from Ubuntu Server.
# Run on Ubuntu 24.04 (amd64 or arm64) as root.
#
# Console image (boot into game client):
#   sudo SHATTERDOMEOS_MODE=console SHATTERDOME_TGZ=Shatterdome-*.tgz ./build-image.sh
#
# Server image (boot into headless game server):
#   sudo SHATTERDOMEOS_MODE=server SHATTERDOME_TGZ=Shatterdome-*.tgz HEADLESS_SCENARIO=scenario_01_empty.lua ./build-image.sh
#
# Output: os/shatterdomeos/out/shatterdomeos-<mode>-<arch>.tar.gz
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then echo "Run as root on Ubuntu: sudo $0"; exit 1; fi

SDOS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "${SDOS_DIR}/../.." && pwd)"
ARCH="${ARCH:-$(dpkg --print-architecture)}"
UBUNTU_CODENAME="${UBUNTU_CODENAME:-noble}"
MODE="${SHATTERDOMEOS_MODE:-console}"
TGZ="${SHATTERDOME_TGZ:-}"
OUT_DIR="${SDOS_DIR}/out"
ROOTFS="${OUT_DIR}/rootfs"

echo "==> ShatterdomeOS image builder"
echo "    Ubuntu ${UBUNTU_CODENAME} ${ARCH} mode=${MODE}"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y debootstrap arch-install-scripts tar gzip

rm -rf "${ROOTFS}"
mkdir -p "${ROOTFS}" "${OUT_DIR}"

echo "==> debootstrap minimal Ubuntu"
debootstrap --arch="${ARCH}" "${UBUNTU_CODENAME}" "${ROOTFS}" http://archive.ubuntu.com/ubuntu/

mount -t proc none "${ROOTFS}/proc"
mount --bind /sys "${ROOTFS}/sys"
mount --bind /dev "${ROOTFS}/dev"
mount -t devpts none "${ROOTFS}/dev/pts"
mount -t tmpfs none "${ROOTFS}/tmp"
cp /etc/resolv.conf "${ROOTFS}/etc/resolv.conf"

# Copy repo + optional TGZ into rootfs for install scripts
mkdir -p "${ROOTFS}/opt/shatterdome-src"
cp -a "${REPO_DIR}/os" "${ROOTFS}/opt/shatterdome-src/os"
cp -a "${REPO_DIR}/tools" "${ROOTFS}/opt/shatterdome-src/tools" 2>/dev/null || true
if [ -n "${TGZ}" ]; then
  cp "${TGZ}" "${ROOTFS}/opt/shatterdome-release.tgz"
fi

INSTALL_ENV="SHATTERDOME_TGZ=/opt/shatterdome-release.tgz"
if [ -z "${TGZ}" ]; then
  INSTALL_ENV="SHATTERDOME_TGZ=auto"
fi

echo "==> chroot: base packages + kernel"
chroot "${ROOTFS}" apt-get update
chroot "${ROOTFS}" apt-get install -y --no-install-recommends \
  linux-image-generic systemd systemd-sysv sudo network-manager \
  openssh-server ca-certificates locales

echo "==> chroot: create shatterdome user"
chroot "${ROOTFS}" useradd -m -s /bin/bash shatterdome || true
echo "shatterdome ALL=(ALL) NOPASSWD:ALL" > "${ROOTFS}/etc/sudoers.d/shatterdome"
chmod 440 "${ROOTFS}/etc/sudoers.d/shatterdome"

echo "==> chroot: install ShatterdomeOS (${MODE})"
if [ "${MODE}" = "server" ]; then
  chroot "${ROOTFS}" env ${INSTALL_ENV} HEADLESS_SCENARIO="${HEADLESS_SCENARIO:-scenario_01_empty.lua}" \
    HEADLESS_NAME="${HEADLESS_NAME:-Shatterdome Bridge}" \
    /bin/bash /opt/shatterdome-src/os/shatterdomeos/install-server.sh
else
  chroot "${ROOTFS}" env ${INSTALL_ENV} SHATTERDOME_USER=shatterdome \
    /bin/bash /opt/shatterdome-src/os/shatterdomeos/install-console.sh
fi

# Default systemd target: multi-user (our service starts the game)
chroot "${ROOTFS}" systemctl set-default multi-user.target

echo "==> cleanup chroot"
rm -rf "${ROOTFS}/opt/shatterdome-src" "${ROOTFS}/opt/shatterdome-release.tgz" 2>/dev/null || true
rm -rf "${ROOTFS}/var/lib/apt/lists/*"

umount "${ROOTFS}/tmp" || true
umount "${ROOTFS}/dev/pts" || true
umount "${ROOTFS}/dev" || true
umount "${ROOTFS}/sys" || true
umount "${ROOTFS}/proc" || true

IMAGE="${OUT_DIR}/shatterdomeos-${MODE}-${ARCH}.tar.gz"
tar -C "${OUT_DIR}" -czf "${IMAGE}" rootfs

echo
echo "Built ${IMAGE}"
echo
echo "To write to a USB/SD card (example — adjust /dev/sdX):"
echo "  sudo wipefs -a /dev/sdX"
echo "  sudo parted /dev/sdX --script mklabel gpt mkpart primary ext4 1MiB 100%"
echo "  sudo mkfs.ext4 -L ShatterdomeOS /dev/sdX1"
echo "  sudo mount /dev/sdX1 /mnt"
echo "  sudo tar -C ${OUT_DIR}/rootfs -xpf - . | sudo tar -C /mnt -xpf -"
echo "  # Install grub for UEFI/BIOS separately for your hardware"
echo
echo "Easier path: install Ubuntu Server on the machine, then run install-console.sh or install-server.sh"
