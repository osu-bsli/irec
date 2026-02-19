/**
 * sensor_registers.cpp
 * 
 * Functions for I2C communication
 *
 * @authors
 * - Diego Noria
*/

#include "sensors/sensor_registers.h"
#include <stdint.h>
#include <Wire.h>

FSError read_registers(
  uint8_t i2c_base_address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
){
  FSError result = SUCCESS;
  
  Wire.beginTransmission(i2c_base_address);
  Wire.write(reg);
  if (Wire.endTransmission() != 0)
  {
    result = FAILURE;
  } else if (Wire.requestFrom(i2c_base_address, length) != length)
  {
    result = FAILURE;
  }
  Wire.readBytes(data, length);

  return result;
}


FSError write_registers(
  uint8_t i2c_base_address,
  uint8_t reg,
  uint8_t *data,
  uint8_t length
){
  FSError result = SUCCESS;
  Wire.beginTransmission(i2c_base_address);
  Wire.write(reg);
  Wire.write(data, length);
  if (Wire.endTransmission()) { result = FAILURE; }
  return result;
}
