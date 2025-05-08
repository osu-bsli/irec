#include <SPI.h>
#include <LoRa.h>

extern "C"
{
#include "slip.h"
}

#define PIN_LED 3

static uint8_t slip_buf[256];

uint8_t write_byte(uint8_t byte)
{
  return 1;
}

void recv_message(uint8_t *data, uint32_t size)
{
  // We've received a SLIP message through the UART. Forward it thru LoRa.

  if (LoRa.beginPacket(true))
  {
    // LoRa is not transmitting, send the packet.
    LoRa.write(data, size);
    LoRa.endPacket(true);
  }
  else
  {
    // LoRa is still transmitting, do nothing
  }
}

static const slip_descriptor_s slip_descriptor = {
    .buf = slip_buf,
    .buf_size = sizeof(slip_buf),
    .crc_seed = 0xFFFF,
    .recv_message = recv_message,
    .write_byte = write_byte,
};

static slip_handler_s slip;
void setup()
{
  LoRa.setSPI(SPI);
  LoRa.setPins(7, 18);
  LoRa.setTxPower(20);
  while (!LoRa.begin(433E6))
  {
    delay(500);
  }

  LoRa.setSignalBandwidth(125E3);
  LoRa.setSpreadingFactor(12);
  LoRa.setPreambleLength(8);

  pinMode(PIN_LED, OUTPUT);

  Serial1.setPins(0, -1);
  Serial1.begin(9600);
  slip_init(&slip, &slip_descriptor);
}

void loop()
{
  while (Serial1.available())
  {
    slip_read_byte(&slip, Serial1.read());
    digitalWrite(PIN_LED, !digitalRead(PIN_LED));
  }
}
