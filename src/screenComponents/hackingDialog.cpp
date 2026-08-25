#include "hackingDialog.h"
#include "signalLockMinigame.h"
#include "playerInfo.h"
#include "gameGlobalInfo.h"
#include "i18n.h"
#include "engine.h"

#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_listbox.h"
#include "gui/gui2_togglebutton.h"
#include "gui/gui2_progressbar.h"
#include "gui/gui2_scrolltext.h"

GuiHackingDialog::GuiHackingDialog(GuiContainer* owner, string id)
: GuiOverlay(owner, id, glm::u8vec4(0,0,0,64))
{
    setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);
    hide();

    minigame_box = new GuiPanel(this, id + "_GAME_BOX");
    minigame_box->setPosition(0, 0, sp::Alignment::Center);
    minigame_box->setSize(600, 545);

    signal_game = new GuiSignalLockMinigame(minigame_box, "SIGNAL");
    signal_game->setPosition(0, 0, sp::Alignment::Center);

    status_label = new GuiLabel(minigame_box, "", "...", 25);
    status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 30);

    hacking_status_label = new GuiLabel(minigame_box, "", "", 25);
    hacking_status_label->setSize(GuiElement::GuiSizeMax, 50)->setPosition(0, 0);

    reset_button = new GuiButton(minigame_box, "", tr("hacking", "Reset"), [this]()
    {
        startSignalHack();
    });
    reset_button->setSize(150.0f, 50.0f);
    reset_button->setPosition(25, -25, sp::Alignment::BottomLeft);

    close_button = new GuiButton(minigame_box, "", tr("button", "Close"), [this]()
    {
        hide();
    });
    close_button->setSize(150.0f, 50.0f);
    close_button->setPosition(-25, -25, sp::Alignment::BottomRight);

    progress_bar = new GuiProgressbar(minigame_box, "", 0, 1, 0.0);
    progress_bar->setPosition(-25, 75, sp::Alignment::TopRight);
    progress_bar->setSize(50, 300);

    target_selection_box = new GuiPanel(this, id + "_BOX");
    target_selection_box
        ->setSize(300.0f, 545.0f)
        ->setPosition(350.0f, 0.0f, sp::Alignment::Center)
        ->setAttribute("layout", "vertical");
    target_selection_box
        ->setAttribute("padding", "20, 20, 0, 20");

    GuiLabel* target_selection_label = new GuiLabel(target_selection_box, "", tr("hacking", "Target system"), 25.0f);
    target_selection_label
        ->addBackground()
        ->setSize(GuiElement::GuiSizeMax, 50.0f)
        ->setAttribute("margin", "0, 20, 0, 0");

    target_list = new GuiListbox(target_selection_box, "TARGET_SYSTEMS",
        [this](int index, string value)
        {
            target_system = ShipSystem::Type(value.toInt());
            startSignalHack();
        });
    target_list->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    target_help = new GuiScrollText(target_selection_box, "MINIGAME_HELP",
        tr("Match the signal waveform by adjusting the sliders until the display reads LOCKED. Complete all signal lock rounds to hack the selected system."));
    target_help
        ->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax)
        ->hide();

    (new GuiToggleButton(target_selection_label, "", "?",
        [this, target_selection_label](bool value)
        {
            target_help->setVisible(value);
            target_list->setVisible(!value);
            target_selection_label->setText(value ? tr("hacking", "Instructions") : tr("hacking", "Target system"));
        }
    ))
        ->setSize(30.0f, 30.0f)
        ->setPosition(0.0f, 0.0f, sp::Alignment::CenterRight);
}

std::pair<int, int> GuiHackingDialog::getHackingComplexityDepth(int difficulty)
{
    switch (difficulty)
    {
    default:
    case 0: return {1, 1};
    case 1: return {2, 1};
    case 2: return {2, 2};
    case 3: return {3, 2};
    }
}

void GuiHackingDialog::startSignalHack()
{
    waiting_for_reset = false;
    last_game_success = false;
    signal_game->clearSessionComplete();

    int difficulty = gameGlobalInfo ? gameGlobalInfo->hacking_difficulty : 2;
    auto [complexity, depth] = getHackingComplexityDepth(difficulty);
    signal_game->setComplexityDepth(complexity, depth);
    signal_game->beginSession();

    target_selection_box->hide();
    minigame_box->setSize(std::max(600.f, signal_game->getSize().x + 100.f), std::max(545.f, signal_game->getSize().y + 150.f));
    progress_bar->setSize(50.0f, signal_game->getSize().y)->setPosition(-25.0f, 75.0f, sp::Alignment::TopRight);
    status_label->setText(tr("hacking", "Hacking in Progress: {percent}%").format({{"percent", string(0)}}));
}

void GuiHackingDialog::open(sp::ecs::Entity target)
{
    this->target = target;
    target_system = ShipSystem::Type::None;
    waiting_for_reset = false;
    show();

    while (target_list->entryCount() > 0)
        target_list->removeEntry(0);
    for (int n = 0; n < int(ShipSystem::Type::COUNT); n++) {
        auto sys = ShipSystem::get(target, ShipSystem::Type(n));
        if (sys && sys->can_be_hacked)
            target_list->addEntry(getLocaleSystemName(ShipSystem::Type(n)), string(n));
    }

    target_selection_box->show();
    signal_game->clearSessionComplete();
}

void GuiHackingDialog::onDraw(sp::RenderTarget& renderer)
{
    if (!target)
    {
        hide();
        return;
    }

    if (target_system != ShipSystem::Type::None && !waiting_for_reset)
    {
        if (signal_game->isSessionComplete())
        {
            waiting_for_reset = true;
            last_game_success = true;
            reset_time = engine->getElapsedTime() + auto_reset_time;
            status_label->setText(tr("Hacking SUCCESS!"));
        }else{
            progress_bar->setValue(signal_game->getProgress());
            status_label->setText(tr("hacking", "Hacking in Progress: {percent}%").format({{"percent", string(int(100 * signal_game->getProgress()))}}));
        }
    }

    if (waiting_for_reset)
    {
        if (engine->getElapsedTime() >= reset_time)
        {
            if (my_spaceship && last_game_success)
                my_player_info->commandHackingFinished(target, target_system);
            target_system = ShipSystem::Type::None;
            waiting_for_reset = false;
            target_selection_box->show();
            status_label->setText("...");
        }else{
            progress_bar->setValue((reset_time - engine->getElapsedTime()) / auto_reset_time);
        }
    }

    if (target_system != ShipSystem::Type::None)
    {
        auto sys = ShipSystem::get(target, target_system);
        if (sys && sys->can_be_hacked)
            hacking_status_label->setText(tr("hacking", "{target}: hacked {percent}%").format({{"target", getLocaleSystemName(target_system)}, {"percent", string(int(sys->hacked_level * 100.0f + 0.5f))}}));
    }

    GuiOverlay::onDraw(renderer);
}

bool GuiHackingDialog::onMouseDown(sp::io::Pointer::Button button, glm::vec2 position, sp::io::Pointer::ID id)
{
    return true;
}
