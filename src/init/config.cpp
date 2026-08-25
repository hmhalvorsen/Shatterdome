#include "config.h"
#include <stringImproved.h>
#include <io/keybinding.h>
#include <preferenceManager.h>
#include "gui/hotkeyConfig.h"
#include <cstring>


string initConfiguration(int argc, char** argv)
{
    string configuration_path = ".";
    if (getenv("EE_CONF_DIR"))
        configuration_path = string(getenv("EE_CONF_DIR"));
    else if (getenv("HOME"))
        configuration_path = string(getenv("HOME")) + "/.shatterdome";
    LOG(Info, "Using ", configuration_path, " as configuration path");
    PreferencesManager::load(configuration_path + "/options.ini");

    for(int n=1; n<argc; n++)
    {
        char* value = strchr(argv[n], '=');
        if (!value) continue;
        *value++ = '\0';
        PreferencesManager::setTemporary(string(argv[n]).strip(), string(value).strip());
    }

    if (PreferencesManager::get("username", "") == "")
    {
        if (getenv("USERNAME"))
            PreferencesManager::setTemporary("username", getenv("USERNAME"));
        else if (getenv("USER"))
            PreferencesManager::setTemporary("username", getenv("USER"));
    }

    sp::io::Keybinding::loadKeybindings(configuration_path + "/keybindings.json");
    return configuration_path;
}
