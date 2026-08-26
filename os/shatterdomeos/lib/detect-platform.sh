#!/bin/bash
is_raspberry_pi() {
  if [ -f /proc/device-tree/model ] && grep -qi raspberry /proc/device-tree/model 2>/dev/null; then
    return 0
  fi
  if grep -qi raspberry /proc/cpuinfo 2>/dev/null; then
    return 0
  fi
  return 1
}

default_console_user() {
  if [ -n "${SHATTERDOME_USER:-}" ]; then
    echo "${SHATTERDOME_USER}"
  elif is_raspberry_pi && id ubuntu >/dev/null 2>&1; then
    echo "ubuntu"
  else
    echo "shatterdome"
  fi
}
