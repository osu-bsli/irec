#pragma once

#include <cstdarg>

#include <FreeRTOS.h>
#include <task.h>

#define OUTPUT 1

#define HIGH 1
#define LOW 1

#define A1 0
#define A2 0

static void pinMode(uint8_t mode, uint8_t is_output) {}
static bool digitalRead(uint8_t pin) { return 1; }
static void digitalWrite(uint8_t pin, uint8_t value) {}
static int analogRead(uint8_t pin) { return 0; }
static void analogReadResolution(uint16_t res) {}
static void tone(uint8_t pin, uint16_t freq, uint16_t duration_ms) {}

static void delay(int ms)
{
  vTaskDelay(ms);
}

long map(long x, long in_min, long in_max, long out_min, long out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

#include <Serial.h>