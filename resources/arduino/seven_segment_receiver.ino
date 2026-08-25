// Minimal receiver for Shatterdome SevenSegmentSerialDevice protocol.
// Parses lines: D<display>:<digits>\n
// Hook showValue() up to your TM1637, MAX7219, or shift-register driver.

#define SERIAL_BAUD 115200

void showValue(int display, const String& text) {
  Serial.print("show display ");
  Serial.print(display);
  Serial.print(" = ");
  Serial.println(text);
}

void setup() {
  Serial.begin(SERIAL_BAUD);
}

void loop() {
  static String line;
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n' || c == '\r') {
      if (line.length() > 0) {
        int colon = line.indexOf(':');
        if (colon > 0 && line.charAt(0) == 'D') {
          int display = line.substring(1, colon).toInt();
          String value = line.substring(colon + 1);
          showValue(display, value);
        }
        line = "";
      }
    } else {
      line += c;
    }
  }
}
