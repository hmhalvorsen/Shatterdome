#!/bin/bash
apply_shatterdomeos_branding() {
  local files_dir="$1"
  install -m 644 "${files_dir}/os-release" /etc/os-release
  ln -sf /etc/os-release /etc/shatterdomeos-release
  hostnamectl set-hostname "${HOSTNAME_TARGET:-shatterdomeos}" 2>/dev/null || echo "${HOSTNAME_TARGET:-shatterdomeos}" > /etc/hostname
  echo "ShatterdomeOS — boot straight into the bridge simulator" > /etc/motd
}
