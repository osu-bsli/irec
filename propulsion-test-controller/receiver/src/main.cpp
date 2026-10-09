#include <Arduino.h>

#include "LoRa.h"
#include "common.h"
#include "checksum.h"

#include <Servo.h>

static void lora_receive_packet_isr_callback(int packet_size);

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
  LoRa.onReceive(lora_receive_packet_isr_callback);
}

static Servo AirBrakeServo;

/*
 * Verifies validity of received packet and write to servo if valid. 
 */
static void lora_receive_packet_isr_callback(int packet_size)
{
  tone(PIN_BUZZER, 900, 250);
  /* we don't need to check packet boundaries here because LoRa already has the idea of packets */

  // discard packets of the wrong size
  if (packet_size != sizeof(command_packet))
    return;

  /* read the received data into buffer */
  uint8_t buf[sizeof(command_packet)];
  for (int i = 0; i < sizeof(command_packet); i++)
  {
    int data_or_neg1 = LoRa.read();

    // if we run out of data while reading, return
    if (data_or_neg1 == -1)
      return;

    buf[i] = data_or_neg1;
  }

  command_packet p;
  memcpy(&p, buf, sizeof(command_packet));

  // if magic doesn't match, return
  if (memcmp(p.magic, PETER_CALLSIGN, sizeof(p.magic)) != 0)
    return;

  /* verify CRC16 match */
  uint16_t p_crc16 = p.crc16;
  p.crc16 = 0;

  uint16_t computed_crc16 = crc_modbus((const unsigned char *)&p, sizeof(struct command_packet));
  // if CRC16 mismatch, return
  if (computed_crc16 != p_crc16)
    return;

  tone(PIN_BUZZER, 1000, 250);

  // Write to Servo
  AirBrakeServo.write(p.servo_write_arg); 
}

void setup()
{
  Serial.begin();
  delay(1000);

  pinMode(PIN_ENABLE_AIRBRAKES, OUTPUT);
  digitalWrite(PIN_ENABLE_AIRBRAKES, HIGH);
  AirBrakeServo.attach(PIN_AIRBRAKES_TX);
  AirBrakeServo.write(90); // according to guy what 
  lora_setup();
  LoRa.receive();

  Serial.println("Servo attached!");
}

void loop()
{
  delay(1000);
}