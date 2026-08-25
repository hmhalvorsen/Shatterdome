#ifndef HARDWARE_CONTROLLER_H
#define HARDWARE_CONTROLLER_H

#include "engine.h"
#include "hardwareOutputDevice.h"
#include "timer.h"
#include "Updatable.h"


class HardwareOutputDevice;
class SevenSegmentSerialDevice;
class HardwareMappingEffect;
class HardwareMappingState
{
public:
    enum EOperator
    {
        Less,
        Greater,
        Equal,
        NotEqual
    };

    string variable;
    EOperator compare_operator;
    float compare_value;
    int channel_nr;

    HardwareMappingEffect* effect;
};
class HardwareMappingEvent
{
public:
    enum EOperator
    {
        Change,
        Increase,
        Decrease
    };

    string trigger_variable;
    float runtime;
    sp::Timer timer;

    EOperator compare_operator;
    bool previous_valid;
    float previous_value;
    int channel_nr;

    HardwareMappingEffect* effect;
};
class SevenSegmentMapping
{
public:
    string device_name;
    int display = 0;
    int digits = 3;
    string variable;
    float min_input = 0.0f;
    float max_input = 100.0f;
};
class HardwareController : public Updatable
{
private:
    std::vector<HardwareOutputDevice*> devices;
    std::unordered_map<string, std::vector<int> > channel_mapping;
    std::vector<HardwareMappingState> states;
    std::vector<HardwareMappingEvent> events;
    std::vector<float> channels;
    std::unordered_map<string, SevenSegmentSerialDevice*> seven_segment_devices;
    std::vector<SevenSegmentMapping> seven_segment_mappings;
public:
    HardwareController() = default;
    ~HardwareController();

    void loadConfiguration(string filename);

    virtual void update(float delta) override;

    bool getVariableValue(string variable_name, float& value);
private:
    void handleConfig(string section, std::unordered_map<string, string>& settings);
    void createNewHardwareMappingState(int channel_number, std::unordered_map<string, string>& settings);
    void createNewHardwareMappingEvent(int channel_number, std::unordered_map<string, string>& settings);
    HardwareMappingEffect* createEffect(std::unordered_map<string, string>& settings);
};

#endif//HARDWARE_CONTROLLER_H
