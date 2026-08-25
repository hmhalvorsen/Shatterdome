#pragma once

#include "preferenceManager.h"

inline bool mvpModeEnabled()
{
    return PreferencesManager::get("mvp_mode", "0") == "1";
}

inline bool hideOnScreenControlsForHardware()
{
    return mvpModeEnabled() || PreferencesManager::get("hardware_console_mode", "0") == "1";
}
