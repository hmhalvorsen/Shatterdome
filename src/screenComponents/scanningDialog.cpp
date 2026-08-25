#include "scanningDialog.h"
#include "signalLockMinigame.h"
#include "i18n.h"
#include "playerInfo.h"
#include "components/scanning.h"
#include "gui/gui2_button.h"
#include "gui/hotkeyConfig.h"

GuiScanningDialog::GuiScanningDialog(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    signal_game = new GuiSignalLockMinigame(this, "SIGNAL");
    signal_game->hide();

    cancel_button = new GuiButton(this, id + "_CANCEL", tr("button", "Cancel"), []() {
        if (my_spaceship)
            my_player_info->commandScanCancel();
    });
    cancel_button->setPosition(0, 280, sp::Alignment::Center)->setSize(300, 50)->hide();
}

void GuiScanningDialog::onDraw(sp::RenderTarget& target)
{
    auto [complexity, depth] = getScanComplexityDepth();
    if (complexity > 0 && depth > 0)
    {
        if (!signal_game->isVisible())
        {
            signal_game->show();
            cancel_button->show();
            signal_game->setComplexityDepth(complexity, depth);
            signal_game->beginSession();
        }

        if (signal_game->isSessionComplete())
        {
            my_player_info->commandScanDone();
            signal_game->clearSessionComplete();
            signal_game->hide();
            cancel_button->hide();
        }
    }else{
        signal_game->hide();
        cancel_button->hide();
    }
}

void GuiScanningDialog::onUpdate()
{
    if (my_spaceship && signal_game->isVisible())
    {
        signal_game->handleScienceKeys();
        if (keys.science_scan_abort.getDown())
            my_player_info->commandScanCancel();
    }
}

std::pair<int, int> GuiScanningDialog::getScanComplexityDepth()
{
    auto ss = my_spaceship.getComponent<ScienceScanner>();
    if (!ss)
        return {0, 0};
    if (!ss->target)
        return {0, 0};
    auto scanstate = ss->target.getComponent<ScanState>();
    if (!scanstate)
        return {0, 0};
    auto complexity = scanstate->complexity;
    auto depth = scanstate->depth;
    if (complexity < 0) {
        switch(gameGlobalInfo->scanning_complexity) {
        case SC_None:
            complexity = 0;
            break;
        case SC_Simple:
            complexity = 1;
            break;
        case SC_Normal:
            if (scanstate->getStateFor(my_spaceship) == ScanState::State::SimpleScan)
                complexity = 2;
            else
                complexity = 1;
            break;
        case SC_Advanced:
            if (scanstate->getStateFor(my_spaceship) == ScanState::State::SimpleScan)
                complexity = 3;
            else
                complexity = 2;
            break;
        }
    }
    if (depth < 0) {
        switch(gameGlobalInfo->scanning_complexity) {
        case SC_None:
        case SC_Simple:
            depth = 1;
            break;
        case SC_Normal:
        case SC_Advanced:
            depth = 2;
            break;
        }
    }
    return {complexity, depth};
}
