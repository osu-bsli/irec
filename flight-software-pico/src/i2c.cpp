/**
 * i2c.cpp
 *
 * i2c communication abstraction.
 *
 * @authors
 * - Diego Noria
*/

#include <stdint.h>
#include <error.h>
#include <i2c.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"

FSError i2c_write(
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
    false,
    1000
  );

  if (reg_write_status == PICO_ERROR_GENERIC) {
    return I2C_REGISTER_WRITE_FAILURE;
  }

  if (reg_write_status == PICO_ERROR_TIMEOUT) {
    return I2C_REGISTER_WRITE_TIMEOUT;
  }

  int data_write_status = i2c_write_timeout_us(
    i2c0,
    address,
    data,
    length,
    false,
    1000
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
    1000
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
    false,
    1000
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
    1000
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
    1000
  );

  if (read_status == PICO_ERROR_GENERIC) {
    return I2C_READ_FAILURE;
  }

  if (read_status == PICO_ERROR_TIMEOUT) {
    return I2C_READ_TIMEOUT;
  }

  return SUCCESS;
}
