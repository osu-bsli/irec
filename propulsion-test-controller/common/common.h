#pragma once

#include <cstring>

#include "checksum.h"

#define PETER_CALLSIGN "KF8HHH"
#define PETER_CALLSIGN_LEN 6

struct __attribute__((packed)) command_packet {
    char magic[PETER_CALLSIGN_LEN]; // Peter's callsign in ASCII with no null terminator
    uint8_t size; // Total size of struct
    uint16_t crc16;

    uint8_t servo_write_arg;
};

// Airbrake servo pin
#define PIN_ENABLE_AIRBRAKES 8
#define PIN_AIRBRAKES_TX 7

#define PIN_LORA_CS 5
#define PIN_LORA_RESET 6
#define PIN_LORA_IRQ_PIN0 0
#define PIN_LORA_SCK 2
#define PIN_LORA_MOSI 3
#define PIN_LORA_MISO 4
#define PIN_BUZZER 26

#define CONFIG_LORA_FREQUENCY_HZ_INITIAL 915 * 1000000

static void command_packet_make_header(struct command_packet *p)
{
  // Copy in magic
  memcpy(p->magic, PETER_CALLSIGN, sizeof(p->magic));
  p->size = sizeof(struct command_packet);

  // Zero out the CRC16 field
  p->crc16 = 0;

  // Write CRC
  p->crc16 = crc_modbus((const unsigned char*)p, sizeof(struct command_packet));
}