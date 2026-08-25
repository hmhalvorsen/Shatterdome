#ifndef SEVEN_SEGMENT_SERIAL_DEVICE_H
#define SEVEN_SEGMENT_SERIAL_DEVICE_H

#include <unordered_map>
#include "stringImproved.h"
#include "timer.h"

class SerialPort;

// Sends numeric values to a 7-segment controller over serial.
// Protocol (one line per update): D<display_index>:<value>\n
// Example: D0:042\n shows "042" on display 0.
class SevenSegmentSerialDevice
{
private:
    SerialPort* port;
    bool virtual_output;
    int resend_delay_ms;
    sp::Timer resend_timer;

    std::unordered_map<int, int> last_values;
    std::unordered_map<int, int> last_digits;

    void sendLine(const string& line);
    string formatValue(int display, int value, int digits);

public:
    SevenSegmentSerialDevice();
    ~SevenSegmentSerialDevice();

    bool configure(std::unordered_map<string, string> settings);

    void setDisplay(int display, int value, int digits);
    void update(float delta);
};

#endif//SEVEN_SEGMENT_SERIAL_DEVICE_H
