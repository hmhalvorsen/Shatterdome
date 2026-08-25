#ifndef SIGNAL_LOCK_MINIGAME_H
#define SIGNAL_LOCK_MINIGAME_H

#include <array>
#include "gui/gui2_element.h"
#include "signalQualityIndicator.h"

class GuiPanel;
class GuiLabel;
class GuiSlider;

// Slider + sinus signal-lock minigame shared by science scanning and relay hacking.
class GuiSignalLockMinigame : public GuiElement
{
public:
    static constexpr int max_sliders = 4;
    static constexpr float lock_delay = 2.0f;

    GuiSignalLockMinigame(GuiContainer* owner, string id);

    void setComplexityDepth(int complexity, int depth);
    void beginSession();
    void beginRound();
    void handleScienceKeys();
    void clearSessionComplete() { session_complete = false; }

    virtual void onDraw(sp::RenderTarget& target) override;

    bool isSessionComplete() const { return session_complete; }
    float getProgress() const;
    bool isLocked() const { return locked; }

private:
    GuiPanel* box;
    GuiLabel* signal_label;
    GuiLabel* locked_label;
    GuiSignalQualityIndicator* signal_quality;
    GuiSlider* sliders[max_sliders];

    float target[max_sliders];
    std::array<bool, max_sliders> set_active = {false, false, false, false};
    bool locked = false;
    float lock_start_time = 0.0f;
    int complexity = 0;
    int depth = 0;
    int current_depth = 0;
    bool session_complete = false;

    void setupParameters();
    void updateSignal();
    string randomSignalLabel() const;
};

#endif//SIGNAL_LOCK_MINIGAME_H
