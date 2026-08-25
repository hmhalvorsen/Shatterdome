# ShatterdomeOS

Ubuntu-based Linux that boots straight into Shatterdome.

**Start here:** [shatterdomeos/README.md](shatterdomeos/README.md)

| Component | Description |
|---|---|
| **[shatterdomeos/](shatterdomeos/)** | ShatterdomeOS — Ubuntu console & server installers, image builder |
| **[netboot/](netboot/)** | Legacy x86 PXE netboot (diskless laptops, wired LAN) |

## Quick start

```bash
# Console station (Ubuntu Server 24.04)
sudo SHATTERDOME_TGZ=Shatterdome-*.tgz ./shatterdomeos/install-console.sh

# Game server
sudo SHATTERDOME_TGZ=Shatterdome-*.tgz ./shatterdomeos/install-server.sh
```

Reboot → game runs automatically. No desktop environment.
