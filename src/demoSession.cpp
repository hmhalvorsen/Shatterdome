#include "demoSession.h"
#include "preferenceManager.h"
#include "crewPosition.h"
#include "logging.h"

static string normalizeStation(string station)
{
    station = station.lower().strip();
    if (station == "helm") return "helms";
    if (station == "weapon") return "weapons";
    if (station == "engineer") return "engineering";
    if (station == "science") return "science";
    if (station == "relay") return "relay";
    return station;
}

static void setDefault(const string& key, const string& value)
{
    if (PreferencesManager::get(key, "").empty())
        PreferencesManager::setTemporary(key, value);
}

void applyDemoSessionPreferences()
{
    const bool demo_client = PreferencesManager::get("demo_mode", "") == "1";
    const bool demo_server = PreferencesManager::get("demo_mode", "") == "server"
        || PreferencesManager::get("demo_server", "") == "1";
    string station = PreferencesManager::get("station", "");

    if (!station.empty())
    {
        station = normalizeStation(station);
        setDefault("autoconnect", station);
        setDefault("instance_name", station);
        setDefault("username", station);
        setDefault("mvp_mode", "1");
        setDefault("autoconnectship", "solo");
        setDefault("demo_mode", "1");
        LOG(INFO) << "Demo station: " << station;
    }

    if (demo_client || !station.empty())
    {
        string server_name = PreferencesManager::get("demo_server_name", "BLACKBRIDGE");
        setDefault("autoconnect_servername", server_name);
        setDefault("mvp_mode", "1");
        setDefault("autoconnectship", "solo");
        // Intentionally no autoconnect_address — LAN discovery via ServerScanner
        LOG(INFO) << "Demo client: searching for server '" << server_name << "' on LAN";
    }

    if (demo_server)
    {
        string scenario = PreferencesManager::get("demo_scenario", "scenario_demo_bridge.lua");
        string server_name = PreferencesManager::get("demo_server_name", "BLACKBRIDGE");

        setDefault("headless", scenario);
        setDefault("headless_name", server_name);
        setDefault("server_port", "35666");
        setDefault("mvp_mode", "1");
        setDefault("startpaused", "0");

        LOG(INFO) << "Demo server: scenario=" << scenario << " name=" << server_name;
    }
}
