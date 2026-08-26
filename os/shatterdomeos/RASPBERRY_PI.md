# ShatterdomeOS on Raspberry Pi

Yes — ShatterdomeOS runs on **Raspberry Pi 4 and 5** using **Ubuntu 24.04 for Raspberry Pi** (arm64).

Raspberry Pi OS (Debian) is not the base — use Canonical's Ubuntu image so you stay on the same ShatterdomeOS stack as PC consoles.

## What you need

- Raspberry Pi 4 (2 GB+) or Pi 5
- MicroSD card (32 GB+)
- HDMI monitor + USB keyboard (for first setup only)
- [Ubuntu 24.04 for Raspberry Pi](https://ubuntu.com/download/raspberry-pi)

## Step-by-step

### 1. Flash Ubuntu

Use Raspberry Pi Imager or balenaEtcher to flash **Ubuntu Server 24.04 LTS (64-bit)** for your Pi model. Enable SSH in imager if you prefer headless setup.

### 2. Build Shatterdome for ARM64

On the Pi itself (slow) or a cross-build machine:

```bash
git clone https://github.com/hmhalvorsen/Shatterdome.git
git clone https://github.com/daid/SeriousProton.git ../SeriousProton
cd Shatterdome
./tools/build-raspberrypi.sh
# TGZ appears in build/
```

Copy the `Shatterdome-*-Linux-ARM64.tgz` to the Pi if built elsewhere.

### 3. Install ShatterdomeOS console mode

```bash
git clone https://github.com/hmhalvorsen/Shatterdome.git
cd Shatterdome/os/shatterdomeos
sudo SHATTERDOME_TGZ=/path/to/Shatterdome-*-Linux-ARM64.tgz ./install-console.sh
sudo reboot
```

The Pi boots straight into Shatterdome — no desktop.

### 4. Configure station

```bash
cat /etc/machine-id
sudo cp consoles/helm.ini.example /etc/shatterdome/consoles/<machine-id>.ini
sudo nano /etc/shatterdome/consoles/<machine-id>.ini
```

Set `autoconnect_address` to your game server IP.

## Pi-specific tweaks (automatic)

The installer detects Raspberry Pi and:

- Uses the `ubuntu` user if present (Ubuntu Pi default)
- Adds GPU/Mesa packages and `modesetting` Xorg config
- Adds the console user to `video`, `render`, `input`, `audio` groups
- Sets `consoleblank=0` on the kernel cmdline

## Server on Pi?

Possible but not recommended for large scenarios — use a PC for the game server. For small test games:

```bash
sudo SHATTERDOME_TGZ=Shatterdome-*-Linux-ARM64.tgz ./install-server.sh
```

## Troubleshooting

| Problem | Fix |
|---|---|
| Black screen after reboot | Check HDMI cable; try `sudo systemctl status shatterdome` |
| Slow graphics | Increase GPU memory in `/boot/firmware/config.txt` (`gpu_mem=128`) |
| Wrong architecture TGZ | Must be **ARM64** TGZ from `build-raspberrypi.sh`, not Windows ZIP |
| Game not found | Verify `/opt/shatterdome/bin/Shatterdome` exists and is executable |

## Hardware consoles

Pair with `hardware.ini` and 7-segment displays — see [SEVEN_SEGMENT.md](../../docs/SEVEN_SEGMENT.md). GPIO/serial works on Pi via `/dev/ttyUSB0` or `/dev/serial0`.
