#pragma once

#define CONFIG_AIRBRAKES_TARGET_APOGEE_METERS 9144
#define CONFIG_RUNTIME_INTERVAL_MS 10
#define CONFIG_ROCKET_MASS_KG 30

/* Check IREC Student Band Plan for allowed frequencies */
#define CONFIG_LORA_FREQUENCY_HZ_INITIAL 905 * 1000000

#define CONFIG_I2C_SENSOR_FREQUENCY 200000

/* All CONFIG_TEST_<> options direct the software to enter a testing mode upon startup. */
/* When a CONFIG_TEST_<> option is enabled, the normal functionality of the flight software DOES NOT RUN. */

// #define CONFIG_TEST_GPS
#ifdef CONFIG_TEST_GPS
// #define CONFIG_TEST_GPS_PRINT_NMEA_TO_SERIAL
#endif

// #define CONFIG_TEST_SENSORS
// #define CONFIG_TEST_FULL_STACK_WITH_PRERECORDED_DATA
// #define CONFIG_TEST_AIRBRAKES_ALGO_PERFORMANCE
// #define CONFIG_TEST_AIRBRAKES_EXTEND_AND_RETRACT
// #define CONFIG_TEST_AIRBRAKES_HITL_CONTROL_ONLY
// #define CONFIG_TEST_AIRBRAKES_HITL_FULL
// #define CONFIG_TEST_ACCEL_CALIBRATION
// #define CONFIG_TEST_NO_PRE_OPERATIONAL_MODE

#ifdef CONFIG_TEST_AIRBRAKES_HITL_FULL
    #undef CONFIG_AIRBRAKES_TARGET_APOGEE_METERS
    #define CONFIG_AIRBRAKES_TARGET_APOGEE_METERS 8000
    #undef CONFIG_ROCKET_MASS_KG
    #define CONFIG_ROCKET_MASS_KG 31.740
#endif

/* CONFIG_TEST_ACTIVE is defined if any test configuration is enabled */
#if defined(CONFIG_TEST_GPS) ||                              \
    defined(CONFIG_TEST_GPS_PRINT_NMEA_TO_SERIAL) ||         \
    defined(CONFIG_TEST_SENSORS) ||                          \
    defined(CONFIG_TEST_FULL_STACK_WITH_PRERECORDED_DATA) || \
    defined(CONFIG_TEST_AIRBRAKES_ALGO_PERFORMANCE) || \
    defined(CONFIG_TEST_AIRBRAKES_EXTEND_AND_RETRACT) || \
    defined(CONFIG_TEST_AIRBRAKES_HITL_CONTROL_ONLY) || \
    defined(CONFIG_TEST_AIRBRAKES_HITL_FULL) || \
    defined(CONFIG_TEST_ACCEL_CALIBRATION) || \
    defined(CONFIG_TEST_NO_PRE_OPERATIONAL_MODE)
#define CONFIG_TEST_ACTIVE
#endif

/* Voltage divider ratio on PIN_VBAT_DIVIDED_TO_ADC.
 * ratio = (R_top + R_bottom) / R_bottom
 * Example: 100k top + 100k bottom → ratio = 2.0
 * Measure the actual resistors on the board and set this accordingly. */
#define CONFIG_VBAT_DIVIDER_RATIO ((100.0 + 10.0) / 10.0)

/*
 * Accelerometer calibration values — applied as: corrected = scale * (raw + offset)
 * Run tools/accel_calibration.m on a CSV produced by CONFIG_TEST_ACCEL_CALIBRATION
 * to compute these values. Defaults are identity (no correction).
 */

// Calibration values are set to identity in HITL_FULL mode because
// already-physical OpenRocket values are injected in HITL mode; 
// applying corrections would corrupt them.
#ifdef CONFIG_TEST_AIRBRAKES_HITL_FULL
    #define CONFIG_CALIB_BMI323_ACCEL_SCALE_X  1.0f
    #define CONFIG_CALIB_BMI323_ACCEL_OFFSET_X 0.0f
    #define CONFIG_CALIB_BMI323_ACCEL_SCALE_Y  1.0f
    #define CONFIG_CALIB_BMI323_ACCEL_OFFSET_Y 0.0f
    #define CONFIG_CALIB_BMI323_ACCEL_SCALE_Z  1.0f
    #define CONFIG_CALIB_BMI323_ACCEL_OFFSET_Z 0.0f

    #define CONFIG_CALIB_ADXL375_ACCEL_SCALE_X  1.0f
    #define CONFIG_CALIB_ADXL375_ACCEL_OFFSET_X 0.0f
    #define CONFIG_CALIB_ADXL375_ACCEL_SCALE_Y  1.0f
    #define CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Y 0.0f
    #define CONFIG_CALIB_ADXL375_ACCEL_SCALE_Z  1.0f
    #define CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Z 0.0f
#else
    /* SN4 calibration, 5/30/2026 */
    #define CONFIG_CALIB_BMI323_ACCEL_SCALE_X  0.99930017f
    #define CONFIG_CALIB_BMI323_ACCEL_OFFSET_X 0.00542708f
    #define CONFIG_CALIB_BMI323_ACCEL_SCALE_Y  1.00056395f
    #define CONFIG_CALIB_BMI323_ACCEL_OFFSET_Y 0.00324385f
    #define CONFIG_CALIB_BMI323_ACCEL_SCALE_Z  0.99932329f
    #define CONFIG_CALIB_BMI323_ACCEL_OFFSET_Z -0.00277153f

    #define CONFIG_CALIB_ADXL375_ACCEL_SCALE_X  1.00720792f
    #define CONFIG_CALIB_ADXL375_ACCEL_OFFSET_X -0.42838153f
    #define CONFIG_CALIB_ADXL375_ACCEL_SCALE_Y  0.96767697f
    #define CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Y -0.33552156f
    #define CONFIG_CALIB_ADXL375_ACCEL_SCALE_Z  1.00165616f
    #define CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Z 0.39474008f
#endif