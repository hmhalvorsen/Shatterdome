# **SHATTERDOME**

**Shatterdome** is a fork of [EmptyEpsilon](https://github.com/daid/EmptyEpsilon), which started as an open-source bridge simulator inspired by [Artemis Spaceship Bridge Simulator](https://www.artemisspaceshipbridge.com/).

This fork is trimmed down for two targets only:

- **Windows** — portable folder or ZIP
- **Raspberry Pi** — Linux ARM install or TGZ package

Removed from upstream: Discord, Steam, Android, macOS packaging, website tooling, netboot images, and other platform extras.

## Requirements

Clone **SeriousProton** next to this repo (same parent folder):

```bash
git clone https://github.com/daid/SeriousProton.git ../SeriousProton
```

### Windows

- CMake
- A C++ toolchain (Visual Studio Build Tools, or MinGW)
- Ninja (recommended)

### Raspberry Pi

- `build-essential`, `cmake`, `ninja-build`, `libsdl2-dev`, `libfreetype6-dev`

## Build

### Windows

From a Developer Command Prompt or shell with `cmake` on PATH:

```bat
tools\build-windows.bat
```

Output:

- `dist\` — runnable game folder (`Shatterdome.exe`, resources, scripts, packs)
- `build\Shatterdome-*.zip` — packaged archive from CPack

Debug build:

```bat
tools\build-windows.bat debug
```

### Raspberry Pi

On the Pi itself:

```bash
./tools/build-raspberrypi.sh
```

Install without apt dependency step:

```bash
INSTALL_DEPS=0 ./tools/build-raspberrypi.sh
```

Custom install location:

```bash
INSTALL_PREFIX=/opt/shatterdome ./tools/build-raspberrypi.sh
```

Output:

- `dist/bin/Shatterdome`
- `dist/share/shatterdome/` — game data
- `build/Shatterdome-*.tar.gz`

## Configuration

Settings live in `~/.shatterdome/options.ini` on Linux, or next to the executable / in `%USERPROFILE%\.shatterdome` on Windows.

Run the built-in tutorial from the main menu to learn the stations.

## Manual CMake (optional)

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DSERIOUS_PROTON_DIR=../SeriousProton
cmake --build build
cmake --install build --prefix dist
cmake --build build --target package
```

## MVP mode (physical consoles)

See [docs/MVP.md](docs/MVP.md). Enable with `mvp_mode=1` in `~/.shatterdome/options.ini` — hides Jump, repair minigame UI, database, beam targeting/lock, and enables auto-repair for crew-based ships.

## Self-hosted CI (optional, free)

To run compile checks on **your own machine** (no GitHub-hosted runner minutes):

```bash
./tools/runner-setup.sh
~/.local/share/shatterdome-actions-runner/start-runner.sh   # leave running
```

Push to `master` triggers `.github/workflows/build-selfhosted.yml`. When finished:

```bash
./tools/runner-teardown.sh
```
