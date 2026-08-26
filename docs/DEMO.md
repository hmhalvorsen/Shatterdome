# Demo session (plug-and-play bridge)

Five consoles + one server, minimal configuration. Power on → play.

## Roles

| Machine | Config | Boots into |
|---|---|---|
| **Server** (1× PC) | `/etc/shatterdome/server.ini` | Headless `scenario_demo_bridge.lua`, LAN name **BLACKBRIDGE** |
| **Helm** | `/etc/shatterdome/station` → `helms` | Autoconnect → Helm station |
| **Weapons** | `weapons` | Weapons station |
| **Engineering** | `engineering` | Engineering station |
| **Science** | `science` | Science station |
| **Relay** | `relay` | Relay station |

No IP addresses on consoles — they **scan the LAN** for server name `BLACKBRIDGE`.

## ShatterdomeOS setup

### 1. Server first (must be on before consoles)

```bash
sudo SHATTERDOME_TGZ=Shatterdome-*.tgz ./os/shatterdomeos/install-server.sh
sudo reboot
```

### 2. Each console

```bash
# Pick ONE station name for this machine:
echo helms | sudo tee /etc/shatterdome/station
# weapons | engineering | science | relay on the other machines

sudo SHATTERDOME_TGZ=Shatterdome-*.tgz ./os/shatterdomeos/install-console.sh
sudo reboot
```

Station name files are in `os/shatterdomeos/demo/stations/` — copy the right one:

```bash
sudo cp os/shatterdomeos/demo/stations/helms /etc/shatterdome/station
```

## Demo day workflow

1. Power **server** → wait ~30s for scenario to load  
2. Power **all 5 consoles** (order doesn't matter)  
3. Each console shows "Searching for server…" then connects to **BLACKBRIDGE**  
4. Crew is on the pre-spawned **Bridge** ship at their stations  

## Manual options.ini (non-ShatterdomeOS)

**Server** (`~/.shatterdome/options.ini`):

```ini
demo_mode=server
demo_scenario=scenario_demo_bridge.lua
demo_server_name=BLACKBRIDGE
mvp_mode=1
```

**Console** (example Helm):

```ini
demo_mode=1
station=helms
mvp_mode=1
autoconnectship=solo
```

Or use legacy keys directly:

```ini
autoconnect=helms
autoconnect_servername=BLACKBRIDGE
autoconnectship=solo
mvp_mode=1
```

## Change scenario

Edit server config before reboot:

```ini
demo_scenario=scenario_20_training1.lua
```

Or: `sudo DEMO_SCENARIO=scenario_20_training1.lua ./install-server.sh`

## Network

- All machines on the **same LAN** (same Wi‑Fi or switch)  
- No fixed IPs required  
- Server advertises as **BLACKBRIDGE** on UDP port 35666  

## Troubleshooting

| Problem | Fix |
|---|---|
| Console stuck on "Searching for server" | Server not running, wrong VLAN, or firewall blocking UDP 35666 |
| Wrong station | Check `/etc/shatterdome/station` contents |
| Two helms on same ship | Each station name must be unique across consoles |
