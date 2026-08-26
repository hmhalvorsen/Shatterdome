# ShatterdomeOS

**ShatterdomeOS** is an Ubuntu-based Linux that boots straight into [Shatterdome](https://github.com/hmhalvorsen/Shatterdome) — no desktop, no main menu.

| Mode | Boots into |
|---|---|
| **Console** | Fullscreen bridge station |
| **Server** | Demo game server (headless) |

Ubuntu 24.04 LTS — PC (amd64) and Raspberry Pi 4/5 (arm64).

> Pi guide: [RASPBERRY_PI.md](RASPBERRY_PI.md)  
> Demo setup: [docs/DEMO.md](../../docs/DEMO.md)

## Plug-and-play demo (5 consoles + server)

**Server first**, then consoles. No IP addresses — LAN auto-discovery.

```bash
# Server (once)
sudo SHATTERDOME_TGZ=Shatterdome-*.tgz ./install-server.sh && sudo reboot

# Each console — set station, then install
echo helms | sudo tee /etc/shatterdome/station   # weapons, engineering, science, relay
sudo SHATTERDOME_TGZ=Shatterdome-*.tgz ./install-console.sh && sudo reboot
```

Station files: `demo/stations/`. Server advertises as **EPSICON**.

## Manual install

Ubuntu Server + `install-console.sh` adds minimal X11 and starts the game on HDMI.

```bash
sudo SHATTERDOME_TGZ=/path/to/Shatterdome-*.tgz ./install-console.sh
sudo reboot
```

## Build rootfs image (advanced)

```bash
sudo SHATTERDOMEOS_MODE=console SHATTERDOME_TGZ=../../Shatterdome-*.tgz ./build-image.sh
```

For Pi SD cards, flashing [Ubuntu for Raspberry Pi](https://ubuntu.com/download/raspberry-pi) + `install-console.sh` is easier.

## Per-station config

Simplest: `/etc/shatterdome/station` containing one word (`helms`, `weapons`, `engineering`, `science`, `relay`).

Or full ini: `/etc/shatterdome/consoles/<machine-id>.ini`

See [docs/DEMO.md](../../docs/DEMO.md) for the full demo workflow.
