#include "hardware.h"

#include "pins.h"
#include "config.h"

#include <Arduino.h>
#include <SPI.h>
#include <pico/stdlib.h>
#include <pico/binary_info.h>
#include <hardware/i2c.h>

/// Due to the nature of the PICO we can configure
/// nearly every pin to do multiple functions.
/// As such all the pin configuration should
/// logically all be in one function.
void gpio_config()
{

  // sensor i2c configuration

  i2c_init(i2c0, CONFIG_I2C_SENSOR_FREQUENCY);
  gpio_set_function(PIN_I2C0_SDA, GPIO_FUNC_I2C);
  gpio_set_function(PIN_I2C0_SCL, GPIO_FUNC_I2C);
  gpio_pull_up(PIN_I2C0_SDA);
  gpio_pull_up(PIN_I2C0_SCL);

  pinMode(PIN_ACTIVITY_LED, OUTPUT);

  bi_decl(bi_2pins_with_func(PIN_I2C0_SDA, PIN_I2C0_SCL, GPIO_FUNC_I2C));

  SPI.setSCK(PIN_LORA_SCK);
  SPI.setMOSI(PIN_LORA_MOSI);
  SPI.setMISO(PIN_LORA_MISO);
}
