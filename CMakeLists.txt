cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

if(DEFINED CPACK_PACKAGE_VERSION_MAJOR)
    set(MAJOR "${CPACK_PACKAGE_VERSION_MAJOR}")
    set(MINOR "${CPACK_PACKAGE_VERSION_MINOR}")
    set(PATCH "${CPACK_PACKAGE_VERSION_PATCH}")
else()
    string(TIMESTAMP MAJOR "%Y")
    string(TIMESTAMP MINOR "%m")
    string(TIMESTAMP PATCH "%d")
endif()

project(Shatterdome LANGUAGES CXX C VERSION ${MAJOR}.${MINOR}.${PATCH})

include(GNUInstallDirs)

set(SERIOUS_PROTON_DIR "../SeriousProton" CACHE PATH "Path to SeriousProton")

message(STATUS "Shatterdome Version = ${PROJECT_VERSION}")
message(STATUS "Supported targets: Windows and Linux (Raspberry Pi)")

# Enable colored output with Ninja
if((CMAKE_GENERATOR MATCHES "Ninja") AND (CMAKE_CXX_COMPILER_ID MATCHES "GNU"))
    add_compile_options (-fdiagnostics-color)
endif()

# Dependencies

# SeriousProton
add_subdirectory("${SERIOUS_PROTON_DIR}" "${PROJECT_BINARY_DIR}/SeriousProton" EXCLUDE_FROM_ALL)

set(EXTERNALS_DIR "${PROJECT_BINARY_DIR}/externals")
set(DOWNLOADS_DIR "${PROJECT_BINARY_DIR}/downloads")
file(MAKE_DIRECTORY "${EXTERNAL_DIR}" "${DOWNLOADS_DIR}")

# Meshoptimizer
set(MESHOPTIMIZER_VERSION 0.23)
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.11)
  include(FetchContent)
  FetchContent_Declare(
    meshoptimizer
    GIT_REPOSITORY https://github.com/zeux/meshoptimizer/
    GIT_TAG "v${MESHOPTIMIZER_VERSION}"
  )
  FetchContent_GetProperties(meshoptimizer)
else()
  # Poor man's FetchContent.
  set(MESHOPTIMIZER_BASE_PATH "${EXTERNALS_DIR}")
  set(meshoptimizer_POPULATED FALSE)
  if(NOT EXISTS "${MESHOPTIMIZER_BASE_PATH}/meshoptimizer/CMakeLists.txt")
    set(MESHOPTIMIZER_ZIP "${DOWNLOADS_DIR}/meshoptimizer.zip")
    file(DOWNLOAD "https://github.com/zeux/meshoptimizer/archive/refs/tags/v${MESHOPTIMIZER_VERSION}.zip" "${MESHOPTIMIZER_ZIP}" TIMEOUT 60 TLS_VERIFY ON)

    execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf "${MESHOPTIMIZER_ZIP}" WORKING_DIRECTORY "${MESHOPTIMIZER_BASE_PATH}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E rename "meshoptimizer-${MESHOPTIMIZER_VERSION}" meshoptimizer WORKING_DIRECTORY "${MESHOPTIMIZER_BASE_PATH}")
  endif()

  set(meshoptimizer_SOURCE_DIR "${MESHOPTIMIZER_BASE_PATH}/meshoptimizer")
  set(meshoptimizer_BINARY_DIR "${PROJECT_BINARY_DIR}/externals/meshoptimizer")
endif()

if(NOT meshoptimizer_POPULATED)
  if(COMMAND FetchContent_Populate)
    FetchContent_Populate(meshoptimizer)
  endif()
  add_subdirectory(${meshoptimizer_SOURCE_DIR} ${meshoptimizer_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

set(GUI_LIB_SOURCES
    src/gui/hotkeyBinder.cpp
    src/gui/hotkeyConfig.cpp
    src/gui/joystickConfig.cpp
    src/gui/mouseRenderer.cpp
    src/gui/gui2_slider.cpp
    src/gui/gui2_togglebutton.cpp
    src/gui/gui2_arrow.cpp
    src/gui/gui2_selector.cpp
    src/gui/gui2_canvas.cpp
    src/gui/gui2_rotationdial.cpp
    src/gui/gui2_textentry.cpp
    src/gui/gui2_label.cpp
    src/gui/gui2_image.cpp
    src/gui/gui2_arrowbutton.cpp
    src/gui/gui2_entrylist.cpp
    src/gui/gui2_progressbar.cpp
    src/gui/gui2_progressslider.cpp
    src/gui/gui2_scrolltext.cpp
    src/gui/gui2_advancedscrolltext.cpp
    src/gui/gui2_button.cpp
    src/gui/gui2_resizabledialog.cpp
    src/gui/debugRenderer.cpp
    src/gui/gui2_element.cpp
    src/gui/gui2_keyvaluedisplay.cpp
    src/gui/gui2_listbox.cpp
    src/gui/gui2_scrollbar.cpp
    src/gui/gui2_container.cpp
    src/gui/gui2_panel.cpp
    src/gui/gui2_overlay.cpp
    src/gui/theme.cpp
    src/gui/layout/layout.cpp
    src/gui/layout/horizontal.cpp
    src/gui/layout/vertical.cpp

    src/gui/debugRenderer.h
    src/gui/gui2_advancedscrolltext.h
    src/gui/gui2_arrowbutton.h
    src/gui/gui2_arrow.h
    src/gui/gui2_button.h
    src/gui/gui2_canvas.h
    src/gui/gui2_container.h
    src/gui/gui2_element.h
    src/gui/gui2_entrylist.h
    src/gui/gui2_image.h
    src/gui/gui2_keyvaluedisplay.h
    src/gui/gui2_label.h
    src/gui/gui2_listbox.h
    src/gui/gui2_overlay.h
    src/gui/gui2_panel.h
    src/gui/gui2_progressbar.h
    src/gui/gui2_progressslider.h
    src/gui/gui2_resizabledialog.h
    src/gui/gui2_rotationdial.h
    src/gui/gui2_scrollbar.h
    src/gui/gui2_scrolltext.h
    src/gui/gui2_selector.h
    src/gui/gui2_slider.h
    src/gui/gui2_textentry.h
    src/gui/gui2_togglebutton.h
    src/gui/theme.h
    src/gui/layout/layout.h
    src/gui/layout/horizontal.h
    src/gui/layout/vertical.h
    src/gui/hotkeyBinder.h
    src/gui/hotkeyConfig.h
    src/gui/joystickConfig.h
    src/gui/mouseRenderer.h
)

set(MAIN_SOURCES
    src/init/config.h
    src/init/config.cpp
    src/init/resources.h
    src/init/resources.cpp
    src/init/displaywindows.h
    src/init/displaywindows.cpp
    src/init/ecs.h
    src/init/ecs.cpp

    src/main.cpp
    src/threatLevelEstimate.cpp
    src/preferenceManager.cpp
    src/epsilonServer.cpp
    src/particleEffect.cpp
    src/httpScriptAccess.cpp
    src/packResourceProvider.cpp
    src/gameGlobalInfo.cpp
    src/demoSession.cpp
    src/GMActions.cpp
    src/script.cpp
    src/crewPosition.cpp
    src/playerInfo.cpp
    src/missileWeaponData.cpp
    src/mesh.cpp
    src/scenarioInfo.cpp
    src/tutorialGame.cpp
    src/shaderRegistry.cpp
    src/glObjects.cpp
    src/stdinLuaConsole.h
    src/stdinLuaConsole.cpp
    src/menus/joinServerMenu.cpp
    src/menus/serverBrowseMenu.cpp
    src/menus/mainMenus.cpp
    src/menus/serverCreationScreen.cpp
    src/menus/tutorialMenu.cpp
    src/menus/optionsMenu.cpp
    src/menus/shipSelectionScreen.cpp
    src/menus/autoConnectScreen.cpp
    src/menus/hotkeyMenu.cpp
    src/menus/luaConsole.cpp
    src/screens/cinematicViewScreen.cpp
    src/screens/crewStationScreen.cpp
    src/screens/topDownScreen.cpp
    src/screens/windowScreen.cpp
    src/screens/mainScreen.cpp
    src/screens/spectatorScreen.cpp
    src/screens/crew4/operationsScreen.cpp
    src/screens/crew4/engineeringAdvancedScreen.cpp
    src/screens/crew4/tacticalScreen.cpp
    src/screens/crew6/engineeringScreen.cpp
    src/screens/crew6/scienceScreen.cpp
    src/screens/crew6/relayScreen.cpp
    src/screens/crew6/weaponsScreen.cpp
    src/screens/crew6/helmsScreen.cpp
    src/screens/crew1/singlePilotScreen.cpp
    src/screens/extra/powerManagement.cpp
    src/screens/extra/databaseScreen.cpp
    src/screens/extra/commsScreen.cpp
    src/screens/extra/shipLogScreen.cpp
    src/screens/gm/gameMasterScreen.cpp
    src/screens/gm/objectCreationView.cpp
    src/screens/gm/globalMessageEntryView.cpp
    src/screens/gm/chatDialog.cpp
    src/screens/gm/tweak.cpp
    src/screenComponents/aimLock.cpp
    src/screenComponents/alertLevelButton.cpp
    src/screenComponents/alertOverlay.cpp
    src/screenComponents/helpOverlay.cpp
    src/screenComponents/missileTubeControls.cpp
    src/screenComponents/selfDestructIndicator.cpp
    src/screenComponents/viewport3d.cpp
    src/screenComponents/viewportMainScreen.cpp
    src/screenComponents/selfDestructEntry.cpp
    src/screenComponents/dockingButton.cpp
    src/screenComponents/shieldsEnableButton.cpp
    src/screenComponents/selfDestructButton.cpp
    src/screenComponents/shieldFreqencySelect.cpp
    src/screenComponents/jumpControls.cpp
    src/screenComponents/impulseControls.cpp
    src/screenComponents/infoDisplay.cpp
    src/screenComponents/frequencyCurve.cpp
    src/screenComponents/noiseOverlay.cpp
    src/screenComponents/powerDamageIndicator.cpp
    src/screenComponents/beamTargetSelector.cpp
    src/screenComponents/beamFrequencySelector.cpp
    src/screenComponents/radarView.cpp
    src/screenComponents/radarZoomSlider.cpp
    src/screenComponents/rawScannerDataRadarOverlay.cpp
    src/screenComponents/scanTargetButton.cpp
    src/screenComponents/snapSlider.cpp
    src/screenComponents/indicatorOverlays.cpp
    src/screenComponents/openCommsButton.cpp
    src/screenComponents/combatManeuver.cpp
    src/screenComponents/rotatingModelView.cpp
    src/screenComponents/shipDestroyedPopup.cpp
    src/screenComponents/warpControls.cpp
    src/screenComponents/targetsContainer.cpp
    src/screenComponents/globalMessage.cpp
    src/screenComponents/commsOverlay.cpp
    src/screenComponents/jumpIndicator.cpp
    src/screenComponents/scanningDialog.cpp
    src/screenComponents/signalLockMinigame.cpp
    src/screenComponents/signalQualityIndicator.cpp
    src/screenComponents/mainScreenControls.cpp
    src/screenComponents/databaseView.cpp
    src/screenComponents/shipsLogControl.cpp
    src/screenComponents/onScreenKeyboard.cpp
    src/screenComponents/hackingDialog.cpp
    src/screenComponents/customShipFunctions.cpp
    src/screenComponents/scrollingBanner.cpp
    src/screenComponents/impulseSound.cpp
    src/components/faction.h
    src/components/faction.cpp
    src/components/radar.h
    src/components/hull.h
    src/components/rendering.h
    src/components/rendering.cpp
    src/components/docking.h
    src/components/coolant.h
    src/components/nanobots.h
    src/components/nanobots.cpp
    src/components/shipsystem.h
    src/components/shipsystem.cpp
    src/components/impulse.h
    src/components/maneuveringthrusters.h
    src/components/warpdrive.h
    src/components/jumpdrive.h
    src/components/reactor.h
    src/components/shields.h
    src/components/shields.cpp
    src/components/beamweapon.h
    src/components/beamweapon.cpp
    src/components/target.h
    src/components/missiletubes.h
    src/components/selfdestruct.h
    src/components/player.h
    src/components/player.cpp
    src/components/pickup.h
    src/components/spin.h
    src/components/rendering.h
    src/components/name.h
    src/components/customshipfunction.h
    src/components/shiplog.h
    src/components/shiplog.cpp
    src/components/comms.h
    src/components/scanning.h
    src/components/scanning.cpp
    src/components/internalrooms.h
    src/components/internalrooms.cpp
    src/components/probe.h
    src/components/hacking.h
    src/components/ai.h
    src/components/radarblock.h
    src/components/gravity.h
    src/components/avoidobject.h
    src/components/sfx.h
    src/components/missile.h
    src/components/database.h
    src/components/zone.h
    src/components/zone.cpp
    src/components/moveto.h
    src/components/lifetime.h
    src/components/destroy.h
    src/systems/ai.h
    src/systems/ai.cpp
    src/systems/docking.h
    src/systems/docking.cpp
    src/systems/shipsystemssystem.h
    src/systems/shipsystemssystem.cpp
    src/systems/coolantsystem.h
    src/systems/coolantsystem.cpp
    src/systems/nanobotsystem.h
    src/systems/nanobotsystem.cpp
    src/systems/energysystem.h
    src/systems/energysystem.cpp
    src/systems/impulse.h
    src/systems/impulse.cpp
    src/systems/maneuvering.h
    src/systems/maneuvering.cpp
    src/systems/beamweapon.h
    src/systems/beamweapon.cpp
    src/systems/missilesystem.h
    src/systems/missilesystem.cpp
    src/systems/warpsystem.h
    src/systems/warpsystem.cpp
    src/systems/jumpsystem.h
    src/systems/jumpsystem.cpp
    src/systems/sfx.h
    src/systems/sfx.cpp
    src/systems/shieldsystem.h
    src/systems/shieldsystem.cpp
    src/systems/damage.h
    src/systems/damage.cpp
    src/systems/selfdestruct.h
    src/systems/selfdestruct.cpp
    src/systems/probe.h
    src/systems/probe.cpp
    src/systems/pickup.h
    src/systems/pickup.cpp
    src/systems/basicmovement.h
    src/systems/basicmovement.cpp
    src/systems/gravity.h
    src/systems/gravity.cpp
    src/systems/comms.h
    src/systems/comms.cpp
    src/systems/radarblock.h
    src/systems/radarblock.cpp
    src/systems/pathfinding.h
    src/systems/pathfinding.cpp
    src/systems/rendering.h
    src/systems/rendering.cpp
    src/systems/scanning.h
    src/systems/scanning.cpp
    src/systems/planet.h
    src/systems/planet.cpp
    src/systems/gm.h
    src/systems/gm.cpp
    src/systems/radar.h
    src/systems/radar.cpp
    src/systems/zone.h
    src/systems/zone.cpp
    src/systems/debugrender.h
    src/systems/debugrender.cpp
    src/systems/destroy.h
    src/systems/destroy.cpp
    src/multiplayer/beamweapon.h
    src/multiplayer/beamweapon.cpp
    src/multiplayer/shields.h
    src/multiplayer/shields.cpp
    src/multiplayer/faction.h
    src/multiplayer/faction.cpp
    src/multiplayer/radar.h
    src/multiplayer/radar.cpp
    src/multiplayer/comms.h
    src/multiplayer/comms.cpp
    src/multiplayer/probe.h
    src/multiplayer/probe.cpp
    src/multiplayer/orbit.h
    src/multiplayer/orbit.cpp
    src/multiplayer/radarblock.h
    src/multiplayer/radarblock.cpp
    src/multiplayer/player.h
    src/multiplayer/player.cpp
    src/multiplayer/name.h
    src/multiplayer/name.cpp
    src/multiplayer/impulse.h
    src/multiplayer/impulse.cpp
    src/multiplayer/warp.h
    src/multiplayer/warp.cpp
    src/multiplayer/jumpdrive.h
    src/multiplayer/jumpdrive.cpp
    src/multiplayer/docking.h
    src/multiplayer/docking.cpp
    src/multiplayer/coolant.h
    src/multiplayer/coolant.cpp
    src/multiplayer/nanobots.h
    src/multiplayer/nanobots.cpp
    src/multiplayer/reactor.h
    src/multiplayer/reactor.cpp
    src/multiplayer/rendering.h
    src/multiplayer/rendering.cpp
    src/multiplayer/selfdestruct.h
    src/multiplayer/selfdestruct.cpp
    src/multiplayer/hull.h
    src/multiplayer/hull.cpp
    src/multiplayer/target.h
    src/multiplayer/target.cpp
    src/multiplayer/database.h
    src/multiplayer/database.cpp
    src/multiplayer/maneuveringthrusters.h
    src/multiplayer/maneuveringthrusters.cpp
    src/multiplayer/hacking.h
    src/multiplayer/hacking.cpp
    src/multiplayer/customshipfunction.h
    src/multiplayer/customshipfunction.cpp
    src/multiplayer/gravity.h
    src/multiplayer/gravity.cpp
    src/multiplayer/scanning.h
    src/multiplayer/scanning.cpp
    src/multiplayer/missile.h
    src/multiplayer/missile.cpp
    src/multiplayer/missiletubes.h
    src/multiplayer/missiletubes.cpp
    src/multiplayer/sfx.h
    src/multiplayer/sfx.cpp
    src/multiplayer/spin.h
    src/multiplayer/spin.cpp
    src/multiplayer/moveto.h
    src/multiplayer/moveto.cpp
    src/multiplayer/internalrooms.h
    src/multiplayer/internalrooms.cpp
    src/multiplayer/shiplog.h
    src/multiplayer/shiplog.cpp
    src/multiplayer/zone.h
    src/multiplayer/zone.cpp
    src/ai/fighterAI.cpp
    src/ai/ai.cpp
    src/ai/aiFactory.cpp
    src/ai/evasionAI.cpp
    src/ai/missileVolleyAI.cpp
    src/hardware/hardwareController.cpp
    src/hardware/hardwareMappingEffects.cpp
    src/hardware/serialDriver.cpp
    src/hardware/devices/dmx512SerialDevice.cpp
    src/hardware/devices/enttecDMXProDevice.cpp
    src/hardware/devices/sACNDMXDevice.cpp
    src/hardware/devices/uDMXDevice.cpp
    src/hardware/devices/virtualOutputDevice.cpp
    src/hardware/devices/philipsHueDevice.cpp
    src/hardware/devices/sevenSegmentSerialDevice.cpp
    src/script/components.cpp
    src/script/dataStorage.h
    src/script/dataStorage.cpp
    src/script/gm.h
    src/script/gm.cpp
    src/script/scriptRandom.h
    src/script/scriptRandom.cpp

    src/ai/aiFactory.h
    src/ai/ai.h
    src/ai/evasionAI.h
    src/ai/fighterAI.h
    src/ai/missileVolleyAI.h
    src/epsilonServer.h
    src/featureDefs.h
    src/gameGlobalInfo.h
    src/demoSession.h
    src/glObjects.h
    src/GMActions.h
    src/hardware/devices/dmx512SerialDevice.h
    src/hardware/devices/enttecDMXProDevice.h
    src/hardware/devices/philipsHueDevice.h
    src/hardware/devices/sACNDMXDevice.h
    src/hardware/devices/uDMXDevice.h
    src/hardware/devices/virtualOutputDevice.h
    src/hardware/devices/sevenSegmentSerialDevice.h
    src/hardware/hardwareController.h
    src/hardware/hardwareMappingEffects.h
    src/hardware/hardwareOutputDevice.h
    src/hardware/serialDriver.h
    src/httpScriptAccess.h
    src/main.h
    src/math/centerOfMass.h
    src/math/triangulate.h
    src/menus/autoConnectScreen.h
    src/menus/hotkeyMenu.h
    src/menus/joinServerMenu.h
    src/menus/mainMenus.h
    src/menus/optionsMenu.h
    src/menus/serverBrowseMenu.h
    src/menus/serverCreationScreen.h
    src/menus/shipSelectionScreen.h
    src/menus/tutorialMenu.h
    src/menus/luaConsole.h
    src/mesh.h
    src/missileWeaponData.h
    src/packResourceProvider.h
    src/particleEffect.h
    src/crewPosition.h
    src/playerInfo.h
    src/preferenceManager.h
    src/scenarioInfo.h
    src/screenComponents/aimLock.h
    src/screenComponents/alertLevelButton.h
    src/screenComponents/alertOverlay.h
    src/screenComponents/beamFrequencySelector.h
    src/screenComponents/beamTargetSelector.h
    src/screenComponents/combatManeuver.h
    src/screenComponents/commsOverlay.h
    src/screenComponents/customShipFunctions.h
    src/screenComponents/databaseView.h
    src/screenComponents/dockingButton.h
    src/screenComponents/frequencyCurve.h
    src/screenComponents/globalMessage.h
    src/screenComponents/hackingDialog.h
    src/screenComponents/helpOverlay.h
    src/screenComponents/impulseControls.h
    src/screenComponents/infoDisplay.h
    src/screenComponents/impulseSound.h
    src/screenComponents/indicatorOverlays.h
    src/screenComponents/jumpControls.h
    src/screenComponents/jumpIndicator.h
    src/screenComponents/mainScreenControls.h
    src/screenComponents/missileTubeControls.h
    src/screenComponents/noiseOverlay.h
    src/screenComponents/onScreenKeyboard.h
    src/screenComponents/openCommsButton.h
    src/screenComponents/powerDamageIndicator.h
    src/screenComponents/radarView.h
    src/screenComponents/radarZoomSlider.h
    src/screenComponents/rawScannerDataRadarOverlay.h
    src/screenComponents/rotatingModelView.h
    src/screenComponents/scanningDialog.h
    src/screenComponents/signalLockMinigame.h
    src/screenComponents/scanTargetButton.h
    src/screenComponents/scrollingBanner.h
    src/screenComponents/selfDestructButton.h
    src/screenComponents/selfDestructEntry.h
    src/screenComponents/selfDestructIndicator.h
    src/screenComponents/shieldFreqencySelect.h
    src/screenComponents/shieldsEnableButton.h
    src/screenComponents/shipDestroyedPopup.h
    src/screenComponents/shipsLogControl.h
    src/screenComponents/signalQualityIndicator.h
    src/screenComponents/snapSlider.h
    src/screenComponents/targetsContainer.h
    src/screenComponents/viewport3d.h
    src/screenComponents/viewportMainScreen.h
    src/screenComponents/warpControls.h
    src/screens/cinematicViewScreen.h
    src/screens/crew1/singlePilotScreen.h
    src/screens/crew4/engineeringAdvancedScreen.h
    src/screens/crew4/operationsScreen.h
    src/screens/crew4/tacticalScreen.h
    src/screens/crew6/engineeringScreen.h
    src/screens/crew6/helmsScreen.h
    src/screens/crew6/relayScreen.h
    src/screens/crew6/scienceScreen.h
    src/screens/crew6/weaponsScreen.h
    src/screens/crewStationScreen.h
    src/screens/extra/commsScreen.h
    src/screens/extra/databaseScreen.h
    src/screens/extra/powerManagement.h
    src/screens/extra/shipLogScreen.h
    src/screens/gm/chatDialog.h
    src/screens/gm/gameMasterScreen.h
    src/screens/gm/globalMessageEntryView.h
    src/screens/gm/objectCreationView.h
    src/screens/gm/tweak.h
    src/screens/mainScreen.h
    src/screens/spectatorScreen.h
    src/screens/topDownScreen.h
    src/screens/windowScreen.h
    src/script.h
    src/shaderRegistry.h
    src/threatLevelEstimate.h
    src/tutorialGame.h
    src/script/components.h
    src/script/vector.h
    src/script/enum.h
)

if (WIN32)
  list(APPEND MAIN_SOURCES Shatterdome.rc)
endif()

configure_file(cmake/config.h.in include/config.h)

if (SHARED_SP)
    set(EE_LIB_TYPE SHARED)
else()
    set(EE_LIB_TYPE STATIC)
endif()

add_library(EE_GuiLIB ${EE_LIB_TYPE} ${GUI_LIB_SOURCES})
target_link_libraries(EE_GuiLIB PUBLIC seriousproton meshoptimizer)
target_include_directories(EE_GuiLIB PUBLIC "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src;${CMAKE_CURRENT_BINARY_DIR}/include>")

add_executable(${PROJECT_NAME} ${MAIN_SOURCES})

if(UNIX AND NOT WIN32)
    target_compile_definitions(${PROJECT_NAME} PUBLIC RESOURCE_BASE_DIR="${CMAKE_INSTALL_FULL_DATADIR}/shatterdome/")
endif()

target_include_directories(${PROJECT_NAME}
    PUBLIC
        "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src;${CMAKE_CURRENT_BINARY_DIR}/include>"
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        seriousproton meshoptimizer EE_GuiLIB
)

if(APPLE)
    target_link_libraries(${PROJECT_NAME} PUBLIC "-framework Foundation")
endif()

if(WIN32 AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_link_libraries(${PROJECT_NAME} PUBLIC "-mconsole")
endif()

if(MSVC)
    set_source_files_properties(src/screens/gm/tweak.cpp PROPERTIES COMPILE_FLAGS "/bigobj")
endif()

include(InstallRequiredSystemLibraries)

set(EE_RESOURCES resources scripts packs)
if(WIN32)
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION .)
    install(DIRECTORY ${EE_RESOURCES} DESTINATION .)
    if(MSVC)
        install(FILES "$<TARGET_PDB_FILE:${PROJECT_NAME}>" DESTINATION . OPTIONAL)
    endif()
else()
    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
    install(DIRECTORY ${EE_RESOURCES} DESTINATION "${CMAKE_INSTALL_DATADIR}/shatterdome")
endif()

set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME};Shatterdome")
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_CHECKSUM SHA256)

if(NOT DEFINED CPACK_GENERATOR)
    if(WIN32)
        set(CPACK_GENERATOR "ZIP")
    else()
        set(CPACK_GENERATOR "TGZ")
    endif()
endif()

set(CPACK_INSTALL_CMAKE_PROJECTS
    "${PROJECT_BINARY_DIR};${PROJECT_NAME};ALL;/"
    "${PROJECT_BINARY_DIR}/SeriousProton;SeriousProton;runtime;/"
)

include(CPack)
