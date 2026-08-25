#include "sevenSegmentSerialDevice.h"
#include "hardware/serialDriver.h"
#include "logging.h"

#include <cmath>

SevenSegmentSerialDevice::SevenSegmentSerialDevice()
: port(nullptr), virtual_output(false), resend_delay_ms(1000)
{
}

SevenSegmentSerialDevice::~SevenSegmentSerialDevice()
{
    if (port)
        delete port;
}

bool SevenSegmentSerialDevice::configure(std::unordered_map<string, string> settings)
{
    if (settings.find("resend_delay") != settings.end())
        resend_delay_ms = std::max(0, settings["resend_delay"].toInt());

    string port_name = settings["port"];
    if (port_name == "" || port_name.lower() == "virtual")
    {
        virtual_output = true;
        LOG(INFO) << "SevenSegmentSerialDevice running in virtual mode (logs only)";
        return true;
    }

    port = new SerialPort(port_name);
    if (!port->isOpen())
    {
        LOG(ERROR) << "Failed to open port: " << port_name << " for SevenSegmentSerialDevice";
        delete port;
        port = nullptr;
        return false;
    }

    int baud = 115200;
    if (settings.find("baud") != settings.end())
        baud = settings["baud"].toInt();
    port->configure(baud, 8, SerialPort::NoParity, SerialPort::OneStopBit);

    LOG(INFO) << "SevenSegmentSerialDevice on " << port_name << " at " << baud << " baud";
    return true;
}

string SevenSegmentSerialDevice::formatValue(int display, int value, int digits)
{
    digits = std::max(1, std::min(8, digits));
    int max_value = 1;
    for (int n = 0; n < digits; n++)
        max_value *= 10;
    max_value -= 1;
    value = std::max(0, std::min(max_value, value));

    string text = string(value);
    while (int(text.length()) < digits)
        text = "0" + text;
    if (int(text.length()) > digits)
        text = text.substr(text.length() - digits);

    return "D" + string(display) + ":" + text + "\n";
}

void SevenSegmentSerialDevice::sendLine(const string& line)
{
    if (virtual_output)
    {
        LOG(INFO) << "7seg " << line.strip();
        return;
    }
    if (port)
        port->send(const_cast<char*>(line.c_str()), int(line.length()));
}

void SevenSegmentSerialDevice::setDisplay(int display, int value, int digits)
{
    if (display < 0)
        return;

    digits = std::max(1, std::min(8, digits));

    auto value_it = last_values.find(display);
    auto digits_it = last_digits.find(display);
    if (value_it != last_values.end() && digits_it != last_digits.end()
        && value_it->second == value && digits_it->second == digits)
        return;

    last_values[display] = value;
    last_digits[display] = digits;
    sendLine(formatValue(display, value, digits));
}

void SevenSegmentSerialDevice::update(float delta)
{
    (void)delta;
    if (resend_delay_ms <= 0 || last_values.empty())
        return;

    if (!resend_timer.isRunning())
        resend_timer.start(float(resend_delay_ms) / 1000.0f);
    if (!resend_timer.isExpired())
        return;

    resend_timer.start(float(resend_delay_ms) / 1000.0f);
    for (const auto& entry : last_values)
    {
        int display = entry.first;
        int digits = last_digits[display];
        sendLine(formatValue(display, entry.second, digits));
    }
}
