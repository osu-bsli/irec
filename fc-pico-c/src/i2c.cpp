/**
 * i2c.cpp
 *
 * i2c communication abstraction.
 *
 * @authors
 * - Diego Noria
*/

#include <Arduino.h>
#include <stdint.h>
#include <error.h>
#include <i2c.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"

#define TIMEOUT_US 1000000
#define DWELL_TIME_MS 10

FSError i2c_write(
  uint8_t address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
) {
  uint8_t write_buf[256] = {0};
  write_buf[0] = reg;
  memcpy(&write_buf[1], data, length);

  int data_write_status = i2c_write_timeout_us(
    i2c0,
    address,
    write_buf,
    length+1,
    false,
    TIMEOUT_US
  );

  if (data_write_status == PICO_ERROR_GENERIC) {
    return I2C_WRITE_FAILURE;
  }

  if (data_write_status == PICO_ERROR_TIMEOUT) {
    return I2C_WRITE_TIMEOUT;
  }

  return SUCCESS;
}

FSError i2c_write_no_reg(
  uint8_t address,
  uint8_t *data,
  uint8_t length
) {
  int data_write_status = i2c_write_timeout_us(
    i2c0,
    address,
    data,
    length,
    false,
    TIMEOUT_US
  );

  if (data_write_status == PICO_ERROR_GENERIC) {
    return I2C_WRITE_FAILURE;
  }

  if (data_write_status == PICO_ERROR_TIMEOUT) {
    return I2C_WRITE_TIMEOUT;
  }

  return SUCCESS;
}

FSError i2c_read(
  uint8_t address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
) {
  int reg_write_status = i2c_write_timeout_us(
    i2c0,
    address,
    &reg,
    1,
    true,
    TIMEOUT_US
  );

  if (reg_write_status == PICO_ERROR_GENERIC) {
    return I2C_REGISTER_READ_FAILURE; // Address not acknowledged or found
  }

  if (reg_write_status == PICO_ERROR_TIMEOUT) {
    return I2C_REGISTER_READ_TIMEOUT; // timeout
  }
  
  int read_status = i2c_read_timeout_us(
    i2c0,
    address,
    data,
    length,
    false,
    TIMEOUT_US
  );

  if (read_status == PICO_ERROR_GENERIC) {
    return I2C_READ_FAILURE; // Address not acknowledged or found
  }

  if (read_status == PICO_ERROR_TIMEOUT) {
    return I2C_READ_TIMEOUT; // timout
  }

  return SUCCESS;
}

FSError i2c_read_no_reg(
  uint8_t address,
  uint8_t *data,
  uint8_t length
) {
  int read_status = i2c_read_timeout_us(
    i2c0,
    address,
    data,
    length,
    false,
    TIMEOUT_US
  );

  if (read_status == PICO_ERROR_GENERIC) {
    return I2C_READ_FAILURE;
  }

  if (read_status == PICO_ERROR_TIMEOUT) {
    return I2C_READ_TIMEOUT;
  }

  return SUCCESS;
}
