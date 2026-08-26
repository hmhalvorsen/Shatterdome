#!/bin/bash
# Extra setup when running ShatterdomeOS on Raspberry Pi (Ubuntu arm64).
configure_raspberry_pi_console() {
  local user="$1"
  echo "==> Raspberry Pi detected: applying Pi console tweaks"

  apt-get install -y --no-install-recommends \
    libgl1-mesa-dri libgles2 mesa-vulkan-drivers \
    2>/dev/null || true

  # Ubuntu for Raspberry Pi firmware (ignore if not in repos)
  apt-get install -y --no-install-recommends linux-firmware-raspi 2>/dev/null || true

  usermod -aG video,render,input,dialout,audio "${user}" 2>/dev/null || true

  mkdir -p /etc/X11/xorg.conf.d
  cat > /etc/X11/xorg.conf.d/20-shatterdomeos-pi.conf << 'EOX'
Section "Device"
    Identifier "RaspberryPi"
    Driver "modesetting"
    Option "AccelMethod" "glamor"
EndSection
EOX

  # Reduce screen blanking on console framebuffer too
  if [ -f /boot/firmware/cmdline.txt ]; then
    CMDLINE=/boot/firmware/cmdline.txt
  elif [ -f /boot/cmdline.txt ]; then
    CMDLINE=/boot/cmdline.txt
  else
    CMDLINE=""
  fi
  if [ -n "${CMDLINE}" ] && ! grep -q 'consoleblank=0' "${CMDLINE}"; then
    sed -i 's/$/ consoleblank=0/' "${CMDLINE}" || true
  fi
}

configure_raspberry_pi_server() {
  echo "==> Raspberry Pi detected: server mode (no extra packages required)"
  apt-get install -y --no-install-recommends linux-firmware-raspi 2>/dev/null || true
}
