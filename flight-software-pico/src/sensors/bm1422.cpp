/**
 * bm1422.c
 *
 * BM1422AGMV 3-Axis Digital Magnetometer IC Driver
 * 
 * Created on: Jan 22, 2025
 *
 * @author:
 * - BSLI
 * - Diego Noria
 */

#include "sensors/bm1422.h"
#include <error.h>
#include <stdio.h>
#include <HardwareSerial.h>
#include <Wire.h>

/*
 * Header files are for sharing things that other C files need.
 * Register addresses should go HERE and not bm1422.h because other C files do not need to see them.
 */

/* I2C constants (Pg. 10) */
#define I2C_ADDRESS 0x0Eu // There is a low and high address
#define WHO_AM_I 0x41

// Register constants (pg. 10)
#define REGISTER_INFO 0x0D // LSB
#define REGISTER_WIA 0x0F
#define REGISTER_DATAX 0x10 // LSB
#define REGISTER_DATAY 0x12 // LSB
#define REGISTER_DATAZ 0x14 // LSB
#define REGISTER_STA1 0x18
#define REGISTER_CNTL1 0x1B
#define REGISTER_CNTL2 0x1C
#define REGISTER_CNTL3 0x1D
#define REGISTER_AVE_A 0x40
#define REGISTER_CNTL4_L 0x5C
#define REGISTER_CNTL4_H 0x5D
#define REGISTER_TEMP 0x60 // LSB
#define REGISTER_OFF_X 0x6C
#define REGISTER_OFF_Y 0x72
#define REGISTER_OFF_Z 0x78
#define REGISTER_FINEOUTPUTX 0x90 // LSB
#define REGISTER_FINEOUTPUTY 0x92 // LSB
#define REGISTER_FINEOUTPUTZ 0x94 // LSB
#define REGISTER_GAIN_PARA_X 0x9C // LSB
#define REGISTER_GAIN_PARA_Y 0x9E // LSB

static FSError read_registers(
	uint8_t reg,
	uint8_t *data,
	uint8_t length
){
	FSError result = SUCCESS;
	Wire.beginTransmission((uint8_t)I2C_ADDRESS);
	Wire.write(reg);
	if (Wire.endTransmission() != 0)
	{
		result = I2C_REGISTER_READ_FAILURE;
	} else if (Wire.requestFrom((uint8_t)I2C_ADDRESS, length) != length)
	{
		result = I2C_REGISTER_READ_FAILURE;
	}
	Wire.readBytes(data, length);

	return result;
}

static FSError write_registers(
	uint8_t reg,
	uint8_t *data,
	uint8_t length
){
	FSError result = SUCCESS;

	Wire.beginTransmission((uint8_t)I2C_ADDRESS);
	Wire.write(reg);
	Wire.write(data, length);

	if (Wire.endTransmission()) {
		result = I2C_REGISTER_WRITE_FAILURE;
	}

	return result;
}

/*
 * Public functions.
 */

FSError fc_bm1422_initialize(struct fc_bm1422 *device)
{
	device->is_in_degraded_state = false;

	/* =================================== */
	/* check that the device id is correct */
	/* =================================== */

	uint8_t data;

	// WHO AM I
	const FSError wia_status = read_registers(REGISTER_WIA, &data, 1);
	if (wia_status != SUCCESS)
	{
		device->is_in_degraded_state = true;
		return BM1422_WHO_AM_I_READ_FAILURE;
	}
	if (data != WHO_AM_I)
	{
		// TODO should incorrect data be outputted??? idk
		//Serial.printf(SENSOR_NAME ": WHO_AM_I mismatch: %d\n\r", data);
		device->is_in_degraded_state = true;
		return BM1422_WHO_AM_I_MISMATCH;
	}

	// power on
	// 14-bit mode
	// ODR = 100 Hz
	// continuous sampling mode
	data = 0b11001000;
	const FSError cntl1_status = write_registers(REGISTER_CNTL1, &data, 1);
	if (cntl1_status != SUCCESS)
	{
		device->is_in_degraded_state = true;
		return BM1422_CNTL1_WRITE_FAILURE;
	}

	// write anything to CNTL4 high byte (0x5D) to set RSTB_LV=1
	data = 0x00;
	const FSError cntl4_status = write_registers(REGISTER_CNTL4_H, &data, 1);
	if (cntl4_status != SUCCESS)
	{
		device->is_in_degraded_state = true;
		return BM1422_CNTL4_WRITE_FAILURE;
	}

	// FORCE (bit 6) = 1 in CNTL3 to start measurements
	data = 0b01000000;
	const FSError cntl3_status = write_registers(REGISTER_CNTL3, &data, 1);
	if (cntl3_status != SUCCESS)
	{
		device->is_in_degraded_state = true;
		return BM1422_CNTL3_WRITE_FAILURE;
	}

	return SUCCESS;
}

FSError fc_bm1422_process(struct fc_bm1422 *device, struct fc_bm1422_data *data)
{
	/* Array for six output data registers (Pg. 12) */
	uint8_t raw_data[6];

	/* Begin i2c read */
	FSError datax_status = read_registers(
		REGISTER_DATAX,
		raw_data,
		sizeof(raw_data)
		);

	if (datax_status != SUCCESS)
	{
		device->is_in_degraded_state = true;
		return BM1422_DATAX_READ_FAILURE;
	}

	int16_t raw_magnetic_strength_x = (int16_t)((raw_data[1] << 8) | raw_data[0]);
	int16_t raw_magnetic_strength_y = (int16_t)((raw_data[3] << 8) | raw_data[2]);
	int16_t raw_magnetic_strength_z = (int16_t)((raw_data[5] << 8) | raw_data[4]);

	float scale = 0.042; // 0.042 microTesla / LSB

	/* Process Raw Data */
	data->magn_x = (float)raw_magnetic_strength_x * scale;
	data->magn_y = (float)raw_magnetic_strength_y * scale;
	data->magn_z = (float)raw_magnetic_strength_z * scale;

	// char buf[64];
	// snprintf(buf, 64, SENSOR_NAME ": mag x: %f\n", data->magnetic_strength_x);
	// SEGGER_RTT_WriteString(0, buf);
	// snprintf(buf, 64, SENSOR_NAME ": mag y: %f\n", data->magnetic_strength_y);
	// SEGGER_RTT_WriteString(0, buf);
	// snprintf(buf, 64, SENSOR_NAME ": mag z: %f\n", data->magnetic_strength_z);
	// SEGGER_RTT_WriteString(0, buf);

	return SUCCESS;
}
