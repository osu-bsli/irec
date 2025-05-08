#include <SPI.h>
#include <HardwareSerial.h>
#include <Arduino.h>

extern "C"
{
#include "telemetry.h"
#include "slip.h"
}

#define PIN_LED 3

static uint8_t slip_buf[256];

void recv_message(uint8_t *data, uint32_t size)
{
}

uint8_t write_byte(uint8_t byte)
{
  return Serial2.write(byte);
}

static const slip_descriptor_s slip_descriptor = {
    .buf = slip_buf,
    .buf_size = sizeof(slip_buf),
    .crc_seed = 0xFFFF,
    .recv_message = recv_message,
    .write_byte = write_byte};

static slip_handler_s slip;

void setup()
{
  Serial2.begin(9600);
  slip_init(&slip, &slip_descriptor);
}

void loop()
{
  struct telemetry_packet tele_p = {
      .status_flags = 0,
      .time_boot_ms = 1234,
      .ms5607_pressure_mbar = 800,
      .ms5607_pressure_mbar_min = 700};
  telemetry_packet_make_header(&tele_p);

  slip_send_message(&slip, (uint8_t *)&tele_p, sizeof(tele_p));

  delay(1000);
}
