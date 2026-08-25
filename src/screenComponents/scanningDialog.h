#ifndef SCANNING_DIALOG_H
#define SCANNING_DIALOG_H

#include "gui/gui2_element.h"
#include "gameGlobalInfo.h"

class GuiButton;
class GuiSignalLockMinigame;

class GuiScanningDialog : public GuiElement
{
private:
    GuiSignalLockMinigame* signal_game;
    GuiButton* cancel_button;

    std::pair<int, int> getScanComplexityDepth();
public:
    GuiScanningDialog(GuiContainer* owner, string id);

    virtual void onDraw(sp::RenderTarget& target) override;
    virtual void onUpdate() override;
};

#endif//SCANNING_DIALOG_H
