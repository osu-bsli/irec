#include <Arduino.h>

#include "LoRa.h"
#include "common.h"
#include "checksum.h"

static void lora_setup()
{
  SPI.setSCK(PIN_LORA_SCK);
  SPI.setMOSI(PIN_LORA_MOSI);
  SPI.setMISO(PIN_LORA_MISO);
  LoRa.setSPI(SPI);
  LoRa.setPins(PIN_LORA_CS, PIN_LORA_RESET, PIN_LORA_IRQ_PIN0);
  if (!LoRa.begin(CONFIG_LORA_FREQUENCY_HZ_INITIAL))
  {
    Serial.println("LoRa initialization failed");
  }
  else
  {
    Serial.println("LoRa initialized successfully");
  }
  LoRa.setGain(6);
}

#define CRLF "\r\n"
#define SEP "================================================================================" CRLF

/* Read a line from Serial with echo and backspace support.
   Blocks until Enter is pressed. */
static void read_line(char *buf, int buf_size)
{
  int i = 0;
  memset(buf, 0, buf_size);
  while (true)
  {
    if (!Serial.available())
      continue;
    int c = Serial.read();
    if (c == '\r' || c == '\n')
    {
      delay(5);
      while (Serial.available() && (Serial.peek() == '\r' || Serial.peek() == '\n'))
        Serial.read();
      Serial.print(CRLF);
      return;
    }
    if ((c == 127 || c == '\b') && i > 0)
    {
      i--;
      buf[i] = '\0';
      Serial.print("\b \b");
    }
    else if (c >= 32 && i < buf_size - 1)
    {
      buf[i++] = (char)c;
      buf[i] = '\0';
      Serial.write((uint8_t)c);
    }
  }
}

void setup()
{
  delay(1000);
  Serial.begin();
  lora_setup();
}

void loop()
{
  /* Prompt for a positive integer value (in Hz) used to retune the LoRa link.
   Returns true and writes *out_value on success, false if cancelled/invalid. */
  Serial.print(CRLF SEP "  ");
  Serial.printf("  Enter the new value in degrees (e.g. 75). Empty line cancels." CRLF);
  Serial.print(
      SEP
      "> ");

  char buf[32];
  read_line(buf, sizeof(buf));

  if (buf[0] == '\0')
  {
    Serial.print("Cancelled." CRLF);
    return;
  }

  char *end = nullptr;
  unsigned long value = strtoul(buf, &end, 10);
  if (end == buf || *end != '\0' || value > 255)
  {
    Serial.print("Invalid value. Command NOT sent." CRLF);
    return;
  }

  /* Send packet to receiver */

  command_packet p;
  memset(&p, 0, sizeof(p));

  p.servo_write_arg = value;

  command_packet_make_header(&p);

  LoRa.beginPacket();
  LoRa.write((uint8_t *)&p, sizeof(p));
  LoRa.endPacket(false);
}