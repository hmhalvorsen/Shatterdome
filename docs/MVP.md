# Shatterdome MVP (meeting notes)

This fork targets a church bridge setup with physical consoles on Raspberry Pi and a PC server.

## Enable MVP mode

Add to `~/.shatterdome/options.ini`:

```ini
mvp_mode=1
```

Optional when wiring physical controls via `hardware.ini`:

```ini
hardware_console_mode=1
```

## What MVP mode changes today

| Meeting decision | Software change |
|---|---|
| Drop Jump (phase 1) | Jump controls hidden on Helm/Tactical/Single Pilot |
| Remove repair minigame | Repair crew, Damage Control station, and internal crew UI removed |
| Nanobot repair | Engineering allocates nanobots from a ship pool to repair systems and unhack |
| Weapons: no beam subsystem picker / lock | Beam target selector and missile lock button hidden; beams default to hull |
| Science: optional remove Database | Database tab/mode hidden on Science; Database station tab removed |
| Hacking: signal-lock minigame | Same sinus slider minigame as science scanning |
| Relay hacking | Uses science-style signal lock minigame |
| Hide on-screen buttons on hardware consoles | Map controls in `hardware.ini`; `hardware_console_mode=1` |

## Hardware (from notes)

- **Server:** Windows PC
- **Consoles:** Raspberry Pi per station
- **Build:** `tools/build-windows.bat` / `tools/build-raspberrypi.sh`

## Still manual / future work

- Physical console layouts (power presets, helm wheel, weapon buttons, trackpads)
- Relay hacking using the science scan UI
- Per-station `hardware.ini` profiles

See [ROADMAP.md](ROADMAP.md) for stretch goals (console client, map table, LARP repair, EPSICON) and crew/recruitment planning.
