# Shatterdome

Bridge simulator fork of [EmptyEpsilon](https://github.com/daid/EmptyEpsilon). Primary target: **Linux** (game server + Raspberry Pi consoles).

## Build

Clone [SeriousProton](https://github.com/daid/SeriousProton) next to this repo:

```bash
git clone https://github.com/daid/SeriousProton.git ../SeriousProton
```

### Linux (server or dev PC)

Install deps once (Ubuntu/Debian):

```bash
sudo apt-get install build-essential cmake ninja-build libsdl2-dev libfreetype6-dev
```

Build and package:

```bash
./tools/build-linux.sh
```

Or install deps via the script:

```bash
INSTALL_DEPS=1 ./tools/build-linux.sh
```

Output:

- `dist/bin/Shatterdome` — runnable binary
- `dist/share/shatterdome/` — game data
- `build/Shatterdome-*.tar.gz` — install package for ShatterdomeOS

Quick compile-only check (no install/package):

```bash
./tools/build-compile-check.sh
```

### Raspberry Pi (ARM64)

Same as Linux on the Pi (or any ARM64 machine):

```bash
./tools/build-raspberrypi.sh
```

Use the TGZ from `build/` with [ShatterdomeOS](os/shatterdomeos/README.md).

## Run

Settings: `~/.shatterdome/options.ini`

Use the main-menu tutorial to learn the stations.

## Docs

- [MVP mode](docs/MVP.md) — simplified controls for physical consoles (`mvp_mode=1`)
- [Demo session](docs/DEMO.md) — five-console bridge setup
- [ShatterdomeOS](os/shatterdomeos/README.md) — boot straight into the game on Linux
