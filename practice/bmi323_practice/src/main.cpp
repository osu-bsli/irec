#include <Arduino.h>
#include <Wire.h>
#include <assert.h>
#include <HardwareSerial.h>

// i2c_read{}

#define CHIP_ID 0x00
#define ERR_REG 0x01
#define STATUS 0X02

#define ACC_DATA_X 0x03
#define ACC_DATA_Y 0x04
#define ACC_DATA_Z 0x05

#define GYR_DATA_X 0x06
#define GYR_DATA_Y 0x07
#define GYR_DATA_Z 0x08

/// This function finds the bmi323 on our i2c line and configures it.
bmi323_init() void
{
}

/// This function acquires angular velocity and accelation data from the bmi323.
bmi_process() void {
  //
}

void setup()
{

  Wire.begin();
  Serial.begin(921600);

  while (true)
  {
    delay(2000);
    Serial.printf("Hello World\n");
  }
}

void loop()
{
}
