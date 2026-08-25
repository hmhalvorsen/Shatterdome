#include "signalLockMinigame.h"
#include "i18n.h"
#include "random.h"
#include "engine.h"
#include "gui/gui2_panel.h"
#include "gui/gui2_label.h"
#include "gui/gui2_slider.h"
#include "gui/hotkeyConfig.h"

GuiSignalLockMinigame::GuiSignalLockMinigame(GuiContainer* owner, string id)
: GuiElement(owner, id)
{
    setSize(500.0f, 545.0f);

    box = new GuiPanel(this, id + "_BOX");
    box->setSize(500.0f, 545.0f)->setPosition(0.0f, 0.0f, sp::Alignment::Center);

    signal_label = new GuiLabel(box, id + "_LABEL", tr("scanning", "Electric signature"), 30);
    signal_label->addBackground()->setPosition(0, 20, sp::Alignment::TopCenter)->setSize(450, 50);

    signal_quality = new GuiSignalQualityIndicator(box, id + "_SIGNAL");
    signal_quality->setPosition(0, 80, sp::Alignment::TopCenter)->setSize(450, 100);

    locked_label = new GuiLabel(signal_quality, id + "_LOCK_LABEL", tr("scanning", "LOCKED"), 50);
    locked_label->setSize(GuiElement::GuiSizeMax, GuiElement::GuiSizeMax);

    for (int n = 0; n < max_sliders; n++)
    {
        sliders[n] = new GuiSlider(box, id + "_SLIDER_" + string(n), 0.0, 1.0, 0.0, [this](float) {
            updateSignal();
        });
        sliders[n]->setPosition(0, 200 + n * 70, sp::Alignment::TopCenter)->setSize(450, 50);
    }
}

void GuiSignalLockMinigame::setComplexityDepth(int complexity_value, int depth_value)
{
    complexity = std::max(0, std::min(max_sliders, complexity_value));
    depth = std::max(1, depth_value);
}

void GuiSignalLockMinigame::beginSession()
{
    session_complete = false;
    current_depth = 0;
    beginRound();
}

void GuiSignalLockMinigame::beginRound()
{
    locked = false;
    lock_start_time = 0.0f;
    setupParameters();
}

string GuiSignalLockMinigame::randomSignalLabel() const
{
    switch (irandom(0, 10))
    {
    default:
    case 0: return tr("scanning", "Electric signature");
    case 1: return tr("scanning", "Biomass frequency");
    case 2: return tr("scanning", "Gravity well signature");
    case 3: return tr("scanning", "Radiation halftime");
    case 4: return tr("scanning", "Radio profile");
    case 5: return tr("scanning", "Ionic phase shift");
    case 6: return tr("scanning", "Infra-red color shift");
    case 7: return tr("scanning", "Doppler stability");
    case 8: return tr("scanning", "Raspberry jam prevention");
    case 9: return tr("scanning", "Infinity impropability");
    case 10: return tr("scanning", "Zerospace audio frequency");
    }
}

void GuiSignalLockMinigame::setupParameters()
{
    locked = false;
    lock_start_time = 0.0f;

    for (int n = 0; n < max_sliders; n++)
    {
        if (n < complexity)
            sliders[n]->show();
        else
            sliders[n]->hide();
    }
    box->setSize(500, 265 + 70 * std::max(1, complexity));
    setSize(box->getSize());

    for (int n = 0; n < max_sliders; n++)
    {
        target[n] = random(0.0f, 1.0f);
        float slider_value = random(0.0f, 1.0f);
        while (fabsf(target[n] - slider_value) < 0.2f)
            slider_value = random(0.0f, 1.0f);
        sliders[n]->setValue(slider_value);
    }
    updateSignal();

    string label = "[" + string(current_depth + 1) + "/" + string(depth) + "] " + randomSignalLabel();
    signal_label->setText(label);
}

void GuiSignalLockMinigame::updateSignal()
{
    float noise = 0.0f;
    float period = 0.0f;
    float phase = 0.0f;
    int visible_slider_count = 0;

    for (int n = 0; n < max_sliders; n++)
    {
        if (sliders[n]->isVisible())
        {
            float error = fabsf(target[n] - sliders[n]->getValue());
            noise += error;
            period += error;
            phase += error;
            visible_slider_count++;
        }
    }

    if (visible_slider_count > 0 && noise < 0.05f && period < 0.05f && phase < 0.05f)
    {
        if (!locked)
        {
            lock_start_time = engine->getElapsedTime();
            locked = true;
        }
        if (engine->getElapsedTime() - lock_start_time > lock_delay / 2.0f)
        {
            noise = period = phase = 0.0f;
        }else{
            float f = 1.0f - (engine->getElapsedTime() - lock_start_time) / (lock_delay / 2.0f);
            noise *= f;
            period *= f;
            phase *= f;
        }
    }else{
        locked = false;
    }

    signal_quality->setNoiseError(noise);
    signal_quality->setPeriodError(period);
    signal_quality->setPhaseError(phase);
}

void GuiSignalLockMinigame::onDraw(sp::RenderTarget& target)
{
    updateSignal();

    if (locked && engine->getElapsedTime() - lock_start_time > lock_delay)
    {
        current_depth += 1;
        if (current_depth >= depth)
        {
            session_complete = true;
            lock_start_time = engine->getElapsedTime() - 1.0f;
        }else{
            beginRound();
        }
    }

    if (locked && engine->getElapsedTime() - lock_start_time > lock_delay / 2.0f)
        locked_label->show();
    else
        locked_label->hide();
}

float GuiSignalLockMinigame::getProgress() const
{
    if (depth <= 0)
        return 0.0f;
    if (session_complete)
        return 1.0f;

    float round_progress = 0.0f;
    if (locked)
        round_progress = std::min(1.0f, (engine->getElapsedTime() - lock_start_time) / lock_delay);

    return std::min(1.0f, (float(current_depth) + round_progress) / float(depth));
}


void GuiSignalLockMinigame::handleScienceKeys()
{
    if (!isVisible())
        return;

    for (int n = 0; n < max_sliders; n++)
    {
        float adjust = (keys.science_scan_param_increase[n].getValue() - keys.science_scan_param_decrease[n].getValue()) * 0.01f;
        if (adjust != 0.0f)
        {
            sliders[n]->setValue(sliders[n]->getValue() + adjust);
            updateSignal();
        }

        float set_value = keys.science_scan_param_set[n].getValue();
        if (set_value != sliders[n]->getValue() && (set_value != 0.0f || set_active[n]))
        {
            sliders[n]->setValue(set_value);
            updateSignal();
            set_active[n] = set_value != 0.0f;
        }
    }
}
