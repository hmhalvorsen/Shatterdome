#pragma once

#include "gui/gui2_overlay.h"
#include "components/shipsystem.h"

class GuiPanel;
class GuiLabel;
class GuiListbox;
class GuiButton;
class GuiToggleButton;
class GuiProgressbar;
class GuiScrollText;
class GuiSignalLockMinigame;

class GuiHackingDialog : public GuiOverlay
{
public:
    GuiHackingDialog(GuiContainer* owner, string id);

    void open(sp::ecs::Entity target);
    virtual void onDraw(sp::RenderTarget& target) override;
    virtual bool onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id) override;

private:
    sp::ecs::Entity target;
    ShipSystem::Type target_system = ShipSystem::Type::None;
    float reset_time = 0.0f;
    static constexpr float auto_reset_time = 2.0f;
    bool waiting_for_reset = false;
    bool last_game_success = false;

    GuiLabel* status_label;
    GuiLabel* hacking_status_label;
    GuiButton* reset_button;
    GuiButton* close_button;
    GuiProgressbar* progress_bar;

    GuiPanel* minigame_box;
    GuiSignalLockMinigame* signal_game;
    GuiPanel* target_selection_box;
    GuiListbox* target_list;
    GuiScrollText* target_help;

    void startSignalHack();
    static std::pair<int, int> getHackingComplexityDepth(int difficulty);
};
