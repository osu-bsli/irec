/**
 * adxl375.c
 *
 * ADXL375 accelerometer driver.
 *
 * @authors
 * - Dawn Goorskey
 * - Hana Winchester
 * - Brian Jia
 * - Diego Noria
 */

#include "sensors/adxl375.h"
#include <HardwareSerial.h>
#include <i2c.h>
#include <error.h>
#include <sensors/sensor_registers.h>

/*
 * Header files are for sharing things that other C files need.
 * Register addresses should go HERE and not adxl375.h because other C files do not need to see them.
 */
 
/* I2C constants */                                                                   
#define DEVICE_ID 0xE5u                                                               
#define I2C_ADDRESS 0x53u 

/* Register constants (pg. 20) */
#define REGISTER_DEVID 0x00u
#define REGISTER_THRESH_SHOCK 0x1Du
#define REGISTER_OFSX 0x1Eu
#define REGISTER_OFSY 0x1Fu
#define REGISTER_OFSZ 0x20u
#define REGISTER_DUR 0x21u
#define REGISTER_LATENT 0x22u
#define REGISTER_WINDOW 0x23u
#define REGISTER_THRESH_ACT 0x24u
#define REGISTER_THRESH_INACT 0x25u
#define REGISTER_TIME_INACT 0x26u
#define REGISTER_ACT_INACT_CTL 0x27u
#define REGISTER_SHOCK_AXES 0x2Au
#define REGISTER_ACT_SHOCK_STATUS 0x2Bu
#define REGISTER_BW_RATE 0x2Cu
#define REGISTER_BW_RATE_LOW_POWER (1 << 4)
#define REGISTER_BW_RATE_100HZ 0b1010
#define REGISTER_POWER_CTL 0x2Du
#define REGISTER_INT_ENABLE 0x2Eu
#define REGISTER_INT_MAP 0x2Fu
#define REGISTER_INT_SOURCE 0x30u
#define REGISTER_DATA_FORMAT 0x31u
#define REGISTER_DATA_FORMAT_SELF_TEST (1 << 7)
#define REGISTER_DATAX0 0x32u
#define REGISTER_DATAX1 0x33u
#define REGISTER_DATAY0 0x34u
#define REGISTER_DATAY1 0x35u
#define REGISTER_DATAZ0 0x36u
#define REGISTER_DATAZ1 0x37u
#define REGISTER_FIFO_CTL 0x38u
#define REGISTER_FIFO_STATUS 0x39u

/*
 * Private functions.
 *
 * Note how these functions are marked static.
 * That means they are inaccessible to other C files. "static" tells the compiler
 * to not export the function as a public symbol.
 *
 * These functions are not prefixed with fc_adxl375_ because they are private
 * and it is obvious what they do.
 */

//static FSError read_registers(
//  uint8_t reg,
//  uint8_t *data,
//  uint8_t length
//){
//  Wire.beginTransmission((uint8_t)I2C_ADDRESS);
//  Wire.write(reg);
//  if (Wire.endTransmission() != 0)
//  {
//    return I2C_REGISTER_READ_FAILURE;
//  }
//
//  if (Wire.requestFrom((uint8_t)I2C_ADDRESS, length) != length)
//  {
//    return I2C_REGISTER_READ_FAILURE;
//  }
//  Wire.readBytes(data, length);
//
//  return SUCCESS;
//}
//
//static FSError write_registers(
//  uint8_t reg,
//  uint8_t *data,
//  uint8_t length
//){
//  Wire.beginTransmission((uint8_t)I2C_ADDRESS);
//  Wire.write(reg);
//  Wire.write(data, length);
//
//  if (Wire.endTransmission()) {
//    return I2C_REGISTER_WRITE_FAILURE;
//  }
//
//  return SUCCESS;
//}

static FSError is_data_ready(
  struct fc_adxl375 *device,
  int *isready
){
  FSError result = SUCCESS;
  uint8_t interrupt_data;

  /* read INT_SOURCE bits (pg. 23) */
  FSError status = i2c_read(
      I2C_ADDRESS,
      REGISTER_INT_SOURCE,
      &interrupt_data,
      sizeof(interrupt_data)
    );

  if (status != SUCCESS)
  {
    result = ADXL375_DATA_READY_READ_FAILURE;
  } else {
    /* ============================= */
    /* DATA_READY is bit D7 (pg. 23) */
    /* ============================= */

    // Shift to ready D7 bit
    // TODO (Brian Jia): Mask off the 7th bit instead of shifting here
    interrupt_data >>= 7;

    // if DATA_READY bit is 1, an interrupt triggered indicating data is ready
    if (interrupt_data == 1)
    {
      *isready = 1;
    }
    else
    {
      *isready = 0;
    }
  }

  return SUCCESS;
}

/*
 * Public functions.
 */

FSError fc_adxl375_initialize(struct fc_adxl375 *device)
{
  /* reset struct */
  device->is_in_degraded_state = false;

  uint8_t data;

  /* Check that device ID is correct */
  FSError device_id_check_status = i2c_read(
    I2C_ADDRESS,
    REGISTER_DEVID,
    &data,
    sizeof(data)
    );
  if (device_id_check_status != SUCCESS) {
    device->is_in_degraded_state = true;
    return ADXL375_DEVICE_ID_READ_FAILURE;
  }
  if (data != DEVICE_ID) {
    //Serial.printf("adxl375: device ID does not match (expected: %d, got: %d)\n\r", DEVICE_ID, data);
    device->is_in_degraded_state = true;
    return ADXL375_DEVICE_ID_MISMATCH;
  }

  /* Set measure bit in POWER_CTL register (pg. 22) */
  data = 0b00001000;
  FSError power_control_status = i2c_write(
    I2C_ADDRESS,
    REGISTER_POWER_CTL,
    &data,
    sizeof(data)
    );
  if (power_control_status != SUCCESS)
  {
    device->is_in_degraded_state = true;
    return ADXL375_POWER_CONTROL_WRITE_FAILURE;
  }

  data = 0b00001011;
  FSError data_format_status = i2c_write(
    I2C_ADDRESS,
    REGISTER_DATA_FORMAT,
    &data,
    sizeof(data)
    );
  if (data_format_status != SUCCESS)
  {
    device->is_in_degraded_state = true;
    return ADXL375_REQUEST_DATA_FORMAT_FAILURE;
  }

  data = REGISTER_BW_RATE_100HZ; // disable low power, 100 Hz
  FSError bw_rate_status = i2c_write(
    I2C_ADDRESS,
    REGISTER_BW_RATE,
    &data,
    sizeof(data)
    );
  if (bw_rate_status != SUCCESS)
  {
    device->is_in_degraded_state = true;
    return ADXL375_WRITE_BW_RATE_FAILURE;
  }

  return SUCCESS;
}

FSError fc_adxl375_process(struct fc_adxl375 *device, struct fc_adxl375_data *data)
{
  FSError result = SUCCESS;

  /* ================================ */
  /* read raw acceleration data bytes */
  /* ================================ */

  uint8_t raw_accel_data[6]; /* DATAX0, X1, Y0, Y1, Z0, and Z1 registers (pg. 24) */

  /* start i2c read */
  FSError register_read_status = i2c_read(
      I2C_ADDRESS,
      REGISTER_DATAX0,
      raw_accel_data,
      sizeof(raw_accel_data)
    );
  if (register_read_status != SUCCESS)
  {
    device->is_in_degraded_state = true;
    return ADXL375_READ_ACCELERATION_FAILURE;
  }

  /* ===================================== */
  /* convert bytes to signed 16-bit values */
  /* ===================================== */

  /* Little endian (pg. 24) */
  int16_t raw_acceleration_x = (raw_accel_data[1] << 8) | raw_accel_data[0];
  int16_t raw_acceleration_y = (raw_accel_data[3] << 8) | raw_accel_data[2];
  int16_t raw_acceleration_z = (raw_accel_data[5] << 8) | raw_accel_data[4];

  /* ============================================ */
  /* convert raw data to actual acceleration data */
  /* ============================================ */

  float scale = 0.049; // (pg. 3) 49 mg/LSB
  data->accel_x = scale * (float)raw_acceleration_x;
  data->accel_y = scale * (float)raw_acceleration_y;
  data->accel_z = scale * (float)raw_acceleration_z;

  /* TODO: Is the ADXL375 on the 24-F01-001 FC damaged????? Readings seem VERY off */
  /* TODO: Maybe I just need to calibrate the accel lmao */
  /* TODO: Yeah it's a high-G accel it needs careful calibration */
  /* TODO: Calibrate the ADXL375 and add code to write the calibration values to the sensor on startup */
  char buf[64];
  // Serial.printf("adxl375: process\n");
  // sprintf(buf, "%f", device->acceleration_x);
  // Serial.printf("adxl375: accel x: %s\n", buf);
  // sprintf(buf, "%f", device->acceleration_y);
  // Serial.printf("adxl375: accel y: %s\n", buf);
  // sprintf(buf, "%f", device->acceleration_z);
  // Serial.printf("adxl375: accel z: %s\n", buf);
  
  return SUCCESS;
}
