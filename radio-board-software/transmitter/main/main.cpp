#include "Arduino.h"

extern "C" void app_main()
{
    initArduino();
    pinMode(5, OUTPUT);

    while (true) {
        digitalWrite(5, HIGH);
        delay(100);
        digitalWrite(5, LOW);
        delay(100);
    }
    
    // Do your own thing
}