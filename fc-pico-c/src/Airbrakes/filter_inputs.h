#pragma once

#include "telemetry.h"
#include "AB_Struct_Storage.h"

/* Populate the sensor fields of AB_Filter_Inputs from a raw log packet.
 *
 * Fills:
 *   Accelerometer_mps2   — low-G (BMI323), calibrated, body→ENU x/y swap
 *   AccelerometerHG_mps2 — high-G (ADXL375), calibrated, X and Y negated
 *   Gyroscope_radps      — BMI323 deg/s converted to rad/s
 *   Magnetometer         — zeroed (sensor not in use)
 *   Barometer_m          — barometric altitude relative to pad
 *
 * The caller is responsible for GPS_Position_m, GPS_Velocity_mps, dt,
 * and IgnoreBaro.
 *
 * Calibration scale/offset constants are taken from config.h
 * (CONFIG_CALIB_BMI323_* and CONFIG_CALIB_ADXL375_*).
 */
void log_packet_v3_fill_filter_inputs(
    const log_packet_v3 &log_p,
    AB_Filter_Inputs &inputs,
    float pad_altitude_m);
