/**
 * i2c.h
 *
 * I2C abstraction because arduino-pico is weird
 *
 * @authors
 * - Diego Noria
*/
#pragma once

#include <stdint.h>
#include <error.h>

FSError i2c_write(
  uint8_t address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
  );
FSError i2c_read(
  uint8_t address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
  );

FSError i2c_write_no_reg(
  uint8_t address,
  uint8_t *data,
  uint8_t length
  );
FSError i2c_read_no_reg(
  uint8_t address,
  uint8_t *data,
  uint8_t length
  );
