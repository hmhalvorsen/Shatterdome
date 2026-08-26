# ShatterdomeOS

**ShatterdomeOS** is Ubuntu-based Linux that boots straight into [Shatterdome](https://github.com/hmhalvorsen/Shatterdome) — no desktop, no main menu.

| Mode | Boots into |
|---|---|
| **Console** | Fullscreen bridge station |
| **Server** | Demo game server (headless) |

Ubuntu 24.04 LTS — PC (amd64) and Raspberry Pi 4/5 (arm64).

> Full setup walkthrough: [docs/INSTALL.md](../../docs/INSTALL.md)  
> Pi guide: [RASPBERRY_PI.md](RASPBERRY_PI.md)

## Quick start

**Server first**, then consoles. LAN auto-discovery — server name **BLACKBRIDGE**.

```bash
sudo SHATTERDOME_TGZ=Shatterdome-*.tar.gz ./install-server.sh && sudo reboot

echo helms | sudo tee /etc/shatterdome/station   # once per console: weapons, engineering, science, relay
sudo SHATTERDOME_TGZ=Shatterdome-*.tar.gz ./install-console.sh && sudo reboot
```

Permanent station role: `/etc/shatterdome/station` (one word per machine).

## Manual install

Ubuntu Server + `install-console.sh` adds minimal X11 and starts the game on HDMI.

```bash
sudo SHATTERDOME_TGZ=/path/to/Shatterdome-*.tar.gz ./install-console.sh
sudo reboot
```

Per-station config: `/etc/shatterdome/station` or `/etc/shatterdome/consoles/<machine-id>.ini`
