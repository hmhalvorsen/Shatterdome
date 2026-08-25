# 7-segment display output

Shatterdome can drive external 7-segment displays over serial. Configure in `~/.shatterdome/hardware.ini`.

## Protocol

Each update is one ASCII line:

```
D<display>:<digits>\n
```

Examples:

- `D0:042` — display 0 shows `042`
- `D1:100` — display 1 shows `100`

Values are zero-padded to the configured digit count. The game only sends when a value changes, plus periodic resends (for controllers that reboot).

## hardware.ini example

See `resources/hardware_seven_segment.ini.example`.

```ini
[hardware]
device=SevenSegmentSerialDevice
name=displays
port=/dev/ttyUSB0
baud=115200
resend_delay=1000

[seven_segment]
device=displays
display=0
digits=3
variable=Hull
min_input=0
max_input=100
```

Use `port=virtual` to log lines to the Shatterdome console instead of opening a serial port (useful for testing).

## Available variables

Any variable from the existing hardware system works, for example:

- `Hull`, `Energy`, `Impulse`, `Warp`
- `FrontShield`, `RearShield`
- `RedAlert`, `YellowAlert`
- System names like `ImpulseHealth`, `ReactorHeat` (no spaces)

## Microcontroller receiver

A minimal Arduino sketch is in `resources/arduino/seven_segment_receiver.ino`. Replace `showValue()` with your TM1637, MAX7219, or shift-register driver.
