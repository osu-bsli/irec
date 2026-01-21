/**
 * ms5607.c
 *
 * MS5607 barometer driver.
 *
 * @authors
 * - Dawn Goorskey
 * - Brian Jia
 * - Amber Phillips
 */

#include <stdio.h>
#include <HardwareSerial.h>
#include <Wire.h>

#include "sensors/ms5607.h"
#include "common.h"

/* i2c constants */
/* THE COMPLEMENT OF THE CSB PIN IS THE LSB OF THE I2C ADDRESS */
#define I2C_ADDRESS 0x76 /* 7 bits, CSB pulled low */

/* TEMPORARY Timeout */
#define I2C_TIMEOUT 100

/* Command Size */
#define COMMAND_SIZE_8BIT 8u

/* constants (pg. 10)
 * These are updated for ms5067
 * OSR = oversampling ratio
 */
#define COMMAND_RESET 0x1Eu
#define COMMAND_CONVERTD1_OSR256 0x40u
#define COMMAND_CONVERTD1_OSR512 0x42u
#define COMMAND_CONVERTD1_OSR1024 0x44u
#define COMMAND_CONVERTD1_OSR2048 0x46u
#define COMMAND_CONVERTD1_OSR4096 0x48u
#define COMMAND_CONVERTD2_OSR256 0x50u
#define COMMAND_CONVERTD2_OSR512 0x52u
#define COMMAND_CONVERTD2_OSR1024 0x54u
#define COMMAND_CONVERTD2_OSR2048 0x56u
#define COMMAND_CONVERTD2_OSR4096 0x58u
#define COMMAND_ADC_READ 0x00u
#define COMMAND_PROM_READ 0xA0u

/* Max and min reading values to check validity of data collected */
#define CONSTANT_PRESSURE_MIN 10.0f     // minimun pressure is 10mbar
#define CONSTANT_PRESSURE_MAX 1200.0f   // minimun pressure is 10mbar
#define CONSTANT_TEMPERATURE_MIN -40.0f // minimun temperature is -40 degrees Celsius
#define CONSTANT_TEMPERATURE_MAX 85.0f  // maximum temperature is 85 degrees Celsius

// datasheet says conversion time is 9.04 ms max for 4096 OSR but let's make it 10 for safety
#define CONVERSION_TIME_MS 10

#define STATE_CONVERTING_PRESSURE 1
#define STATE_CONVERTING_TEMPERATURE 2

/* Double check all data + data lengths */
static esp_err_t write_registers(struct fc_ms5607 *device, uint8_t *data, uint16_t size)
{
    Wire.beginTransmission((uint8_t)I2C_ADDRESS);
    Wire.write(data, size);
    if (Wire.endTransmission() != 0)
    {
        return ESP_FAIL;
    }

    return ESP_OK;
}

static esp_err_t read_registers(struct fc_ms5607 *device, uint8_t *data, uint16_t size)
{
    if (Wire.requestFrom((uint8_t)I2C_ADDRESS, size) != size)
    {
        return ESP_FAIL;
    }
    Wire.readBytes(data, size);

    return ESP_OK;
}

esp_err_t start_temperature_conversion(struct fc_ms5607 *device)
{
    uint8_t command = COMMAND_CONVERTD2_OSR4096; // use highest OSR for now
    return write_registers(device, &command, 1);
}

esp_err_t start_pressure_conversion(struct fc_ms5607 *device)
{
    uint8_t command = COMMAND_CONVERTD1_OSR4096; // use highest OSR for now
    return write_registers(device, &command, 1);
}

esp_err_t read_temperature_data(struct fc_ms5607 *device)
{
    uint8_t command = COMMAND_ADC_READ;
    esp_err_t status = write_registers(device, &command, 1);
    if (status != ESP_OK)
    {
        return status;
    }

    uint8_t temp_bytes[3]; // Big-endian byte 0 = 23-16 byte 1 = 8-15 byte 2 = 7-0
    status = read_registers(device, temp_bytes, 3);
    if (status != ESP_OK)
    {
        return status;
    }

    device->D2 = (temp_bytes[0] << 16) | (temp_bytes[1] << 8) | (temp_bytes[2]);

    return status;
}

esp_err_t read_pressure_data(struct fc_ms5607 *device)
{
    uint8_t command = COMMAND_ADC_READ;
    esp_err_t status = write_registers(device, &command, 1);
    if (status != ESP_OK)
    {
        return status;
    }

    uint8_t pressure_bytes[3]; // Big-endian byte 0 = 23-16 byte 1 = 8-15 byte 2 = 7-0
    status = read_registers(device, pressure_bytes, 3);
    if (status != ESP_OK)
    {
        return status;
    }

    device->D1 = (pressure_bytes[0] << 16) | (pressure_bytes[1] << 8) | (pressure_bytes[2]);

    return status;
}

void calculate_pressure_and_temperature_from_data(struct fc_ms5607 *device)
{
    /*
     * TEMPERATURE CALCULATION (p. 8)
     */

    int32_t dT = device->D2 - ((int32_t)device->C[5] * 256);    // D2 - T_ref
    int32_t TEMP = 2000 + (((int64_t)dT * device->C[6]) >> 23); // 20.0 C + dT * TEMPSENS (2000+dT*C6/2^23)

    /*
     * PRESSURE CALCULATION (p. 8)
     */

    int64_t OFF = (((int64_t)device->C[2]) << 17) + (((int64_t)device->C[4] * (int64_t)dT) >> 6);
    int64_t SENS = (((int64_t)device->C[1]) << 16) + (((int64_t)device->C[3] * (int64_t)dT) >> 7);

    /*
     * SECOND ORDER TEMPERATURE COMPENSATION (p. 9)
     */

    int64_t T2, OFF2, SENS2;
    // Low Temperature
    if (TEMP < 2000)
    {
        T2 = ((int64_t)dT * (int64_t)dT) >> 31;
        OFF2 = 61 * ((int64_t)(TEMP - 2000) * (int64_t)(TEMP - 2000)) >> 4;
        SENS2 = 2 * ((int64_t)(TEMP - 2000) * (int64_t)(TEMP - 2000));

        // Very low temperature
        if (TEMP < -1500)
        {
            OFF2 += 15 * ((int64_t)(TEMP + 1500)) * ((int64_t)(TEMP + 1500));
            SENS2 += 8 * ((int64_t)(TEMP + 1500)) * ((int64_t)(TEMP + 1500));
        }

        TEMP -= T2;
        OFF -= OFF2;
        SENS -= SENS2;
    }

    int64_t P = ((((int64_t)device->D1 * SENS) >> 21) - OFF) >> 15;
    device->last_pressure_mbar = (float)P / 100.0f;
    device->last_temperature_c = TEMP / 100.0f; // Convert from centiCelcius to Celsius

    char buf[64];
    // Check validity of conversions - values must be between min and max values on data sheet
    if (device->last_pressure_mbar < 10.0f || device->last_pressure_mbar > 1200.0f)
    {
        sprintf(buf, "%f", device->last_pressure_mbar);
        Serial.printf("ms5607: pressure_mbar out of range: %s\n", buf);
    }

    if (device->last_temperature_c < -40.0f || device->last_temperature_c > 85.0f)
    {
        sprintf(buf, "%f", device->last_temperature_c);
        Serial.printf("ms5607: temperature_c out of range: %s\n", buf);
    }
}

/* Initialize MS5607 barometer I2C device */
esp_err_t fc_ms5607_initialize(struct fc_ms5607 *device)
{
    /* reset struct */
    device->is_in_degraded_state = false;

    esp_err_t status;

    /*
     * PROM read sequence. Reads in C1-C6.
     */
    for (int i = 0; i <= 6; i++)
    {
        uint8_t command = COMMAND_PROM_READ | (i << 1);
        status = write_registers(device, &command, 1);
        if (status != ESP_OK)
        {
            goto error;
        }

        uint8_t data[2];
        status = read_registers(device, data, 2);
        if (status != ESP_OK)
        {
            goto error;
        }

        device->C[i] = u8_to_u16(data[1], data[0]);
    }

    // Serial.printf("ms5607: PROM C1: %d\n", device->C[1]);
    // Serial.printf("ms5607: PROM C2: %d\n", device->C[2]);
    // Serial.printf("ms5607: PROM C3: %d\n", device->C[3]);
    // Serial.printf("ms5607: PROM C4: %d\n", device->C[4]);
    // Serial.printf("ms5607: PROM C5: %d\n", device->C[5]);
    // Serial.printf("ms5607: PROM C6: %d\n", device->C[6]);

    /* Do a full data read and conversion now so there's data ready immediately after initialization */
    status = start_temperature_conversion(device);
    if (status != ESP_OK)
    {
        goto error;
    }

    vTaskDelay(CONVERSION_TIME_MS);

    status = read_temperature_data(device);
    if (status != ESP_OK)
    {
        goto error;
    }

    status = start_pressure_conversion(device);
    if (status != ESP_OK)
    {
        goto error;
    }

    vTaskDelay(CONVERSION_TIME_MS);

    status = read_pressure_data(device);
    if (status != ESP_OK)
    {
        goto error;
    }

    calculate_pressure_and_temperature_from_data(device);

    /* Initialize the state machine */
    status = start_temperature_conversion(device);
    if (status != ESP_OK)
    {
        goto error;
    }
    device->conversion_started_ms = xTaskGetTickCount();
    device->state = STATE_CONVERTING_TEMPERATURE;

    // Initialization succeeded
    return ESP_OK;

error:
    Serial.printf("ms5607: init failure\n");
    device->is_in_degraded_state = true;
    return status;
}

/* Process to read and convert pressure and temperature */
esp_err_t fc_ms5607_process(struct fc_ms5607 *device, struct fc_ms5607_data *data)
{
    esp_err_t status;

    /* Yes I know we have an RTOS but I don't wanna make things too complex rn */
    switch (device->state)
    {
    case STATE_CONVERTING_TEMPERATURE:
        if (xTaskGetTickCount() - device->conversion_started_ms > CONVERSION_TIME_MS)
        {
            status = read_temperature_data(device);
            if (status != ESP_OK)
            {
                goto error;
            }

            status = start_pressure_conversion(device);
            if (status != ESP_OK)
            {
                goto error;
            }
            device->conversion_started_ms = xTaskGetTickCount();
            device->state = STATE_CONVERTING_PRESSURE;
        }
        break;
    case STATE_CONVERTING_PRESSURE:
        if (xTaskGetTickCount() - device->conversion_started_ms > CONVERSION_TIME_MS)
        {
            status = read_pressure_data(device);
            if (status != ESP_OK)
            {
                goto error;
            }

            status = start_temperature_conversion(device);
            if (status != ESP_OK)
            {
                goto error;
            }
            device->conversion_started_ms = xTaskGetTickCount();
            device->state = STATE_CONVERTING_TEMPERATURE;

            calculate_pressure_and_temperature_from_data(device);
        }
        break;
    }

    data->pressure_mbar = device->last_pressure_mbar;
    data->temperature_c = device->last_temperature_c;

    // Serial.printf("ms5607: process\n");
    // sprintf(buf, "%f", data->pressure_mbar);
    // Serial.printf("ms5607: pressure_mbar: %s\n", buf);
    // sprintf(buf, "%f", data->temperature_c);
    // Serial.printf("ms5607: temperature_c: %s\n", buf);

    return ESP_OK;

error:
    device->is_in_degraded_state = true;
    return status;
}
