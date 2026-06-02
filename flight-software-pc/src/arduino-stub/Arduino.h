#pragma once

#include <cstdarg>

#include <FreeRTOS.h>
#include <task.h>

#define OUTPUT 1
#define HIGH 1

static void pinMode(uint8_t mode, uint8_t is_output) {};
static void digitalWrite(uint8_t pin, uint8_t value) {};
static void analogReadResolution(uint16_t res) {};
static void tone(uint8_t pin, uint16_t freq, uint16_t duration_ms) {};

static void delay(int ms)
{
    vTaskDelay(ms);
}

class SerialClass {
public:
    void begin(int baud);

    int printf(const char *fmt, ...)
    {
        va_list args;
        va_start(args, fmt);
        int ret = vprintf(fmt, args);
        va_end(args);
        return ret;
    }

    int println(const char* str)
    {
        int ret = printf(str);
        ret += printf("\n");
        return ret;
    }
};

static SerialClass Serial;