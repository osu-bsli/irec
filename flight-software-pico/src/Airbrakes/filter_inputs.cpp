#define _USE_MATH_DEFINES
#include <math.h>

#include "filter_inputs.h"
#include "AB_Filter_Main.h" // G_CONST
#include "config.h"         // CONFIG_CALIB_*

void log_packet_v3_fill_filter_inputs(
    const log_packet_v3 &log_p,
    AB_Filter_Inputs &inputs,
    float pad_altitude_m)
{
    // Low-G accelerometer: apply calibration then map body→ENU (sensor X and Y
    // are swapped relative to the ENU East and North axes on this airframe).
    const float bmi323_x_cal = CONFIG_CALIB_BMI323_ACCEL_SCALE_X * (log_p.bmi323_accel_x_G + CONFIG_CALIB_BMI323_ACCEL_OFFSET_X);
    const float bmi323_y_cal = CONFIG_CALIB_BMI323_ACCEL_SCALE_Y * (log_p.bmi323_accel_y_G + CONFIG_CALIB_BMI323_ACCEL_OFFSET_Y);
    const float bmi323_z_cal = CONFIG_CALIB_BMI323_ACCEL_SCALE_Z * (log_p.bmi323_accel_z_G + CONFIG_CALIB_BMI323_ACCEL_OFFSET_Z);
    inputs.Accelerometer_mps2 << bmi323_y_cal * G_CONST,
                                  bmi323_x_cal * G_CONST,
                                  bmi323_z_cal * G_CONST;

    // High-G accelerometer: apply calibration; X and Y are negated to align
    // with the ENU frame on this airframe.
    const float adxl375_x_cal = CONFIG_CALIB_ADXL375_ACCEL_SCALE_X * (log_p.adxl375_accel_x_G + CONFIG_CALIB_ADXL375_ACCEL_OFFSET_X);
    const float adxl375_y_cal = CONFIG_CALIB_ADXL375_ACCEL_SCALE_Y * (log_p.adxl375_accel_y_G + CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Y);
    const float adxl375_z_cal = CONFIG_CALIB_ADXL375_ACCEL_SCALE_Z * (log_p.adxl375_accel_z_G + CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Z);
    inputs.AccelerometerHG_mps2 << -adxl375_x_cal * G_CONST,
                                    -adxl375_y_cal * G_CONST,
                                     adxl375_z_cal * G_CONST;

    inputs.Gyroscope_radps << log_p.bmi323_gyro_x_degps * (float)(M_PI / 180.0),
                              log_p.bmi323_gyro_y_degps * (float)(M_PI / 180.0),
                              log_p.bmi323_gyro_z_degps * (float)(M_PI / 180.0);

    inputs.Magnetometer.setZero();

    inputs.Barometer_m = get_altitude_from_pressure_pa(log_p.ms5607_pressure_mbar * 100.0f) - pad_altitude_m;
}
