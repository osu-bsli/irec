/**
 * main.cpp
 *
 * Main
 *
 * @authors
 * - BSLI
 * - Brian Jia
 * - Diego Noria
 */

#include "config.h"

// C
#include <charconv>
#include <cstdint>
#include <stdio.h>
#include <string>

// Flight Computer
#include <error.h>
#include "pins.h"
#include "test_data.h"
#include "telemetry.h"
#include "logging.h"
#include <error.h>
#include "sensors.h"
#include "gps.h"
#include "hardware.h"

// AirBrakes
#include "Filters/AB_Filter_Main.h"
#include "AB_Struct_Storage.h"
#include "AB_Deployment.h"
#include "filter_inputs.h"

// Arduino
#include <Arduino.h>
#include <SPI.h>
#include <Servo.h>
#include <LoRa.h>
#include <SD.h>

// FreeRTOS
#include <FreeRTOS.h>
#include <queue.h>

#include "instrumentation.h"
#include "testing/testing.h"
#include <checksum.h>

#define I2C_PRESSURE_TRANSDUCER_FREQUENCY 400000  

#define MAX_SERVO_CURRENT_AMPS 2.2

#define ADC_RESOLUTION_BITS 12

// FreeRTOS tick is 1ms when using Arduino like this
// 20ms for 50hz, 10ms for 100hz, 4 for 250hz, 3 for 333.33hz, 2.5 for 400hz, 2 for 500hz
const static TickType_t RUNTIME_INTERVAL_MS = CONFIG_RUNTIME_INTERVAL_MS; // 100 Hz
const static TickType_t SERVO_OVERCURRENT_INTERVAL_MS = 10;               // 100 Hz
const static TickType_t DEPLOY_INTERVAL_MS = 100;                         // 10 Hz
const static TickType_t TELEMETRY_INTERVAL_MS = 1000;                     // 1 Hz
// const static TickType_t error_interval_ms = 100; // 10 Hz

bool sdcard_is_in_degraded_state = false;

/* Landing detection state. Written only by runtime_task (via detect_landing),
 * read by sdcard_write_task to schedule the post-landing SD card shutoff.
 * g_rocket_landed_tick is in the FreeRTOS tick domain (xTaskGetTickCount), not
 * the log-packet time domain, so sdcard_write_task can compare it against its
 * own tick count even when HITL injects foreign timestamps into log packets. */
static volatile bool g_rocket_landed = false;
static volatile TickType_t g_rocket_landed_tick = 0;

// GPS reference point, locked by gps_compute_enu() on the first valid fix.
// All ENU position outputs are relative to this point. Works for both live
// NMEA and serial-injected GPS (OpenRocket HITL).
static bool   gps_has_reference = false;
static double gps_ref_lat_deg   = 0.0;
static double gps_ref_lng_deg   = 0.0;
static float  gps_ref_alt_m     = 0.0f;

#define AIRBRAKE_STOWED_ANGLE 91
#define AIRBRAKE_DEPLOYED_ANGLE 33
static Servo AirBrakeServo;
/* Not static: the HITL/SITL sensor path (sensors.cpp / sitl_sensors.cpp) writes
 * this commanded deployment percentage back to the test host. */
uint8_t g_airbrake_pct = 0;

static volatile uint16_t g_servo_current_ma = 0;

static volatile uint32_t g_runtime_task_iter_us = 0;
static volatile uint32_t g_runtime_task_iter_max_us = 0;
static volatile uint32_t g_deploy_task_iter_us = 0;
static volatile uint32_t g_deploy_task_iter_max_us = 0;
static volatile uint32_t g_servo_overcurrent_task_iter_us = 0;
static volatile uint32_t g_servo_overcurrent_task_iter_max_us = 0;
static volatile uint32_t g_sdcard_write_task_iter_us = 0;
static volatile uint32_t g_sdcard_write_task_iter_max_us = 0;

#define C5_HZ 587
#define NOTE(n) (C5_HZ * pow(2, (n / 12.0)))
#define BEEP(n) tone(PIN_BUZZER, NOTE(n), 100)

struct AirbrakesPacket
{
  struct apogeeIC ic;
} AirbrakesPacket;

static AB_Settings ab_settings = AB_Default_Settings();

#define STATIC_QUEUE_DECLARE_HELPER(name, len, type)                                        \
  typedef type name##_queue_type;                                                           \
  static const uint32_t name##_queue_len = len;                                             \
  static StaticQueue_t name##_queue_data;                                                   \
  static uint8_t name##_queue_storage_buffer[name##_queue_len * sizeof(name##_queue_type)]; \
  static QueueHandle_t name##_queue

STATIC_QUEUE_DECLARE_HELPER(airbrakes, 1, struct AirbrakesPacket);
STATIC_QUEUE_DECLARE_HELPER(log, 100, log_packet_latest);
STATIC_QUEUE_DECLARE_HELPER(radio_command_rx, 100, struct command_packet);

QueueHandle_t get_radio_command_rx_queue_handle()
{
  return radio_command_rx_queue;
}

/* Lets the SITL host set the GNC target apogee at runtime (the flight build
 * uses CONFIG_AIRBRAKES_TARGET_APOGEE_METERS from config.h). */
void set_target_apogee_m(float meters)
{
  ab_settings.TargetApogee_m = meters;
}

/* SITL model-error injection: override the GNC's assumed rocket mass and the
 * scale of its modeled airbrake drag (1.0 = nominal). */
void set_rocket_mass_kg(float kg)
{
  ab_settings.Mass_kg = kg;
}

void set_drag_scale(float scale)
{
  ab_settings.DragScale = scale;
}

#define STATIC_QUEUE_INIT_HELPER(name) \
  name##_queue = xQueueCreateStatic(   \
      name##_queue_len,                \
      sizeof(name##_queue_type),       \
      name##_queue_storage_buffer,     \
      &name##_queue_data);

static uint8_t get_status_flags()
{
  uint8_t result = get_sensor_status_flags();
  if (sdcard_is_in_degraded_state)
  {
    result |= STATUS_FLAGS_SD_CARD_DEGRADED;
  }

  return result;
}

struct calibrated_accel_readings {
  float bmi323_x_cal;
  float bmi323_y_cal;
  float bmi323_z_cal;
  float adxl375_x_cal;
  float adxl375_y_cal;
  float adxl375_z_cal;
};

static calibrated_accel_readings apply_accelerometer_calibrations(log_packet_latest log_p)
{
  const float bmi323_x_cal = CONFIG_CALIB_BMI323_ACCEL_SCALE_X * (log_p.bmi323_accel_x_G + CONFIG_CALIB_BMI323_ACCEL_OFFSET_X);
  const float bmi323_y_cal = CONFIG_CALIB_BMI323_ACCEL_SCALE_Y * (log_p.bmi323_accel_y_G + CONFIG_CALIB_BMI323_ACCEL_OFFSET_Y);
  const float bmi323_z_cal = CONFIG_CALIB_BMI323_ACCEL_SCALE_Z * (log_p.bmi323_accel_z_G + CONFIG_CALIB_BMI323_ACCEL_OFFSET_Z);
  const float adxl375_x_cal = CONFIG_CALIB_ADXL375_ACCEL_SCALE_X * (log_p.adxl375_accel_x_G + CONFIG_CALIB_ADXL375_ACCEL_OFFSET_X);
  const float adxl375_y_cal = CONFIG_CALIB_ADXL375_ACCEL_SCALE_Y * (log_p.adxl375_accel_y_G + CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Y);
  const float adxl375_z_cal = CONFIG_CALIB_ADXL375_ACCEL_SCALE_Z * (log_p.adxl375_accel_z_G + CONFIG_CALIB_ADXL375_ACCEL_OFFSET_Z);

  calibrated_accel_readings cal = {
    .bmi323_x_cal = bmi323_x_cal,
    .bmi323_y_cal = bmi323_y_cal,
    .bmi323_z_cal = bmi323_z_cal,
    .adxl375_x_cal = adxl375_x_cal,
    .adxl375_y_cal = adxl375_y_cal,
    .adxl375_z_cal = adxl375_z_cal,
  };

  return cal;
}

int motor_map(int pct)
{
  return map(pct, 0, 100, AIRBRAKE_STOWED_ANGLE, AIRBRAKE_DEPLOYED_ANGLE);
}

// static void print_log_packet(struct log_packet_latest p) {
//   // %u is poo poo and C doesn't support printing char as a number so we have to use this work around for those values smaller than a word
//   const uint32_t status_flags = 0 | p.status_flags;
//   const uint32_t crc = 0 | p.crc16;
//   const uint32_t num_sats = 0 | p.gps_num_sats;
//   Serial.printf(
//     "[Packet Print]\n\rmagic: %c%c%c%c%c%c%c%c%c\n\rsize: %u\n\rcrc: %02x\n\rstatus flags: %u\n\rtime_boot_ms: %u\n\rms5607_pressure_mbar: %f\n\rms5607_temperature_c: %f\n\rbmi323_accel_x: %f\n\rbmi323_accel_y: %f\n\rbmi323_accel_z: %f\n\rbmi323_gyro_x: %f\n\rbmi323_gyro_y: %f\n\rbmi323_gyro_z: %f\n\radxl375_accel_x: %f\n\radxl375_accel_y: %f\n\radxl375_accel_z: %f\n\rbm1422_magn_x: %f\n\rbm1422_magn_y: %f\n\rbm1422_magn_z: %f\n\rgps_lat: %f\n\rgps_lng: %f\n\rgps_alt: %f\n\rgps_speed: %f\n\rgps_course: %lu\n\rgps_num_sats: %u\n\rpt_volts: %f\n\r",
//     p.magic[0],
//     p.magic[1],
//     p.magic[2],
//     p.magic[3],
//     p.magic[4],
//     p.magic[5],
//     p.magic[6],
//     p.magic[7],
//     p.magic[8],
//     p.magic[9],
//     p.size,
//     crc,
//     status_flags,
//     p.time_boot_ms,
//     p.ms5607_pressure_mbar,
//     p.ms5607_temperature_c,
//     p.bmi323_accel_x,
//     p.bmi323_accel_y,
//     p.bmi323_accel_z,
//     p.bmi323_gyro_x,
//     p.bmi323_gyro_y,
//     p.bmi323_gyro_z,
//     p.adxl375_accel_x,
//     p.adxl375_accel_y,
//     p.adxl375_accel_z,
//     p.bm1422_magn_x,
//     p.bm1422_magn_y,
//     p.bm1422_magn_z,
//     p.gps_lat,
//     p.gps_lng,
//     p.gps_alt,
//     p.gps_speed,
//     p.gps_course,
//     num_sats,
//     p.pt_volts
//   );
// }


/* Convert log-packet GPS fields to ENU (East, North, Up) metres and horizontal
   velocity in m/s, relative to the reference point captured at first valid fix.

   GPS_Position_m layout expected by AB_Filter_Inputs:
     x = East (m), y = North (m), z = Up (m)

   GPS_Velocity_mps layout expected by AB_Filter_Inputs:
     x = East (m/s), y = North (m/s), z = Up (m/s)

   The pad reference point is locked on the first call with a valid (non-NaN)
   fix.  This is driven entirely off the log packet's GPS fields, so it works
   identically whether those fields came from live NMEA (real flight) or were
   injected over serial by the OpenRocket HITL harness.

   Returns true when a valid conversion was possible (reference locked + fix
   valid).  On false, callers should fall back to setZero(). */
static bool gps_compute_enu(const log_packet_latest &log_p,
                             float *east_m, float *north_m, float *up_m,
                             float *vel_east_mps, float *vel_north_mps)
{
  /* Guard against blank-packet sentinels */
  if (isnan(log_p.gps_lat_deg) || isnan(log_p.gps_lng_deg) || isnan(log_p.gps_alt_m))
    return false;

  if (!gps_has_reference)
  {
    gps_ref_lat_deg   = log_p.gps_lat_deg;
    gps_ref_lng_deg   = log_p.gps_lng_deg;
    gps_ref_alt_m     = log_p.gps_alt_m;
    gps_has_reference = true;
  }

  constexpr double R_EARTH_M = 6371000.0;
  const double ref_lat_rad = gps_ref_lat_deg * (M_PI / 180.0);

  *north_m = (float)((log_p.gps_lat_deg - gps_ref_lat_deg) * (M_PI / 180.0) * R_EARTH_M);
  *east_m  = (float)((log_p.gps_lng_deg - gps_ref_lng_deg) * (M_PI / 180.0) * R_EARTH_M * cos(ref_lat_rad));
  *up_m    = log_p.gps_alt_m - gps_ref_alt_m;

  /* Course is stored as hundredths of degrees; sentinel -0x7FFFFFFF means no data. */
  if (!isnan(log_p.gps_speed_mps) && log_p.gps_course != -0x7FFFFFFF)
  {
    const float course_rad = (float)log_p.gps_course / 100.0f * (float)(M_PI / 180.0);
    *vel_east_mps  = log_p.gps_speed_mps * sinf(course_rad);
    *vel_north_mps = log_p.gps_speed_mps * cosf(course_rad);
  }
  else
  {
    *vel_east_mps  = 0.0f;
    *vel_north_mps = 0.0f;
  }

  return true;
}

void airbrakes_setup()
{
  // Allow current to the air brakes
  pinMode(PIN_ENABLE_AIRBRAKES, OUTPUT);
  digitalWrite(PIN_ENABLE_AIRBRAKES, HIGH);

  AirBrakeServo.attach(PIN_AIRBRAKES_TX, 900, 2100);

  // Current sense setup
  analogReadResolution(ADC_RESOLUTION_BITS);
}

void print_sensor_data(const log_packet_latest &log_p)
{
  Serial.printf(
      "======== Sensor data ========\n"
      "    ms5607_pressure_mbar: %f\n"
      "    ms5607_temperature_c: %f\n"
      "          bmi323_accel_x: %f\n"
      "          bmi323_accel_y: %f\n"
      "          bmi323_accel_z: %f\n"
      "           bmi323_gyro_x: %f\n"
      "           bmi323_gyro_y: %f\n"
      "           bmi323_gyro_z: %f\n"
      "         adxl375_accel_x: %f\n"
      "         adxl375_accel_y: %f\n"
      "         adxl375_accel_z: %f\n"
      "           bm1422_magn_x: %f\n"
      "           bm1422_magn_y: %f\n"
      "           bm1422_magn_z: %f\n",
      log_p.ms5607_pressure_mbar,
      log_p.ms5607_temperature_c,
      log_p.bmi323_accel_x_G,
      log_p.bmi323_accel_y_G,
      log_p.bmi323_accel_z_G,
      log_p.bmi323_gyro_x_degps,
      log_p.bmi323_gyro_y_degps,
      log_p.bmi323_gyro_z_degps,
      log_p.adxl375_accel_x_G,
      log_p.adxl375_accel_y_G,
      log_p.adxl375_accel_z_G,
      log_p.bm1422_magn_x,
      log_p.bm1422_magn_y,
      log_p.bm1422_magn_z);
}

void PredictDeploymentAngle_print_params(const apogeeIC ic)
{
  Serial.printf("======== PredictDeploymentAngle parameters =========\n");
  Serial.printf("                altitude_m: %f\n", ic.altitude_m);
  Serial.printf("             velocityZ_mps: %f\n", ic.velocityZ_mps);
  Serial.printf("                thetaZ_rad: %f\n", ic.thetaZ_rad);
  Serial.printf("    airbrakeDeployment_pct: %f\n", ic.airbrakeDeployment_pct);
}

static log_packet_latest get_blank_log_packet()
{
  log_packet_latest log_p = {
      .status_flags = 0,
      .time_boot_ms = 0,
      .ms5607_pressure_mbar = NAN,
      .ms5607_temperature_c = NAN,
      .bmi323_accel_x_G = NAN, // LOW G
      .bmi323_accel_y_G = NAN,
      .bmi323_accel_z_G = NAN,
      .bmi323_gyro_x_degps = NAN,
      .bmi323_gyro_y_degps = NAN,
      .bmi323_gyro_z_degps = NAN,
      .adxl375_accel_x_G = NAN, // HIGH G
      .adxl375_accel_y_G = NAN,
      .adxl375_accel_z_G = NAN,
      .bm1422_magn_x = NAN,
      .bm1422_magn_y = NAN,
      .bm1422_magn_z = NAN,
      .gps_lat_deg = NAN,
      .gps_lng_deg = NAN,
      .gps_alt_m = NAN,
      .gps_speed_mps = NAN,
      .pt_volts = NAN,
      .gps_course = -0x7FFFFFFF,
      .gps_num_sats = 0xFF,
  };

  return log_p;
}

static uint16_t read_battery_voltage_mV()
{
  return (uint16_t)(((float)analogRead(PIN_VBAT_DIVIDED_TO_ADC) / ((1 << ADC_RESOLUTION_BITS) - 1)) * 3.3f * CONFIG_VBAT_DIVIDER_RATIO * 1000.0f);
}

static telemetry_packet fill_out_and_read_things_for_telemetry_packet(log_packet_latest log_p, float thetaZ_rad)
{
  calibrated_accel_readings cal = apply_accelerometer_calibrations(log_p);

  telemetry_packet telemetry_p = {
      .status_flags = log_p.status_flags,
      .time_boot_ms = log_p.time_boot_ms,
      .runtime_task_iter_us = (uint16_t)g_runtime_task_iter_us, 
      .runtime_task_iter_max_us = (uint16_t)g_runtime_task_iter_max_us, 
      .deploy_task_iter_us = (uint16_t)g_deploy_task_iter_us,
      .deploy_task_iter_max_us = (uint16_t)g_deploy_task_iter_max_us,
      .servo_overcurrent_task_iter_us = (uint16_t)g_servo_overcurrent_task_iter_us,
      .servo_overcurrent_task_iter_max_us = (uint16_t)g_servo_overcurrent_task_iter_max_us,
      .sdcard_write_task_iter_us = (uint16_t)g_sdcard_write_task_iter_us,
      .sdcard_write_task_iter_max_us = (uint16_t)g_sdcard_write_task_iter_max_us,
      .battery_mV = read_battery_voltage_mV(),
      .airbrakes_servo_mA = g_servo_current_ma,
      .is_in_operational_mode = 1,
      .altitude_angle_mrad = (uint16_t)((M_PI / 2.0f - thetaZ_rad) * 1000.0f),
      .ms5607_pressure_mbar = log_p.ms5607_pressure_mbar,
      .ms5607_temperature_c = log_p.ms5607_temperature_c,
      .bmi323_accel_magnitude_milliG = (uint16_t)(sqrtf(
                                                      log_p.bmi323_accel_x_G * log_p.bmi323_accel_x_G +
                                                      log_p.bmi323_accel_y_G * log_p.bmi323_accel_y_G +
                                                      log_p.bmi323_accel_z_G * log_p.bmi323_accel_z_G) *
                                                  1000.0f),
      .adxl375_accel_magnitude_milliG = (uint16_t)(sqrtf(
                                                       log_p.adxl375_accel_x_G * log_p.adxl375_accel_x_G +
                                                       log_p.adxl375_accel_y_G * log_p.adxl375_accel_y_G +
                                                       log_p.adxl375_accel_z_G * log_p.adxl375_accel_z_G) *
                                                   1000.0f),
      .bmi323_accel_magnitude_cal_milliG = (uint16_t)(sqrtf(
                                                          cal.bmi323_x_cal * cal.bmi323_x_cal +
                                                          cal.bmi323_y_cal * cal.bmi323_y_cal +
                                                          cal.bmi323_z_cal * cal.bmi323_z_cal) *
                                                      1000.0f),
      .adxl375_accel_magnitude_cal_milliG = (uint16_t)(sqrtf(
                                                           cal.adxl375_x_cal * cal.adxl375_x_cal +
                                                           cal.adxl375_y_cal * cal.adxl375_y_cal +
                                                           cal.adxl375_z_cal * cal.adxl375_z_cal) *
                                                       1000.0f),
      .commanded_airbrake_deploy_pct = g_airbrake_pct,
      .gps_lat_deg = log_p.gps_lat_deg,
      .gps_lng_deg = log_p.gps_lng_deg,
      .gps_alt_m = log_p.gps_alt_m,
      .gps_num_sats = log_p.gps_num_sats,
  };

  return telemetry_p;
}

/* Detect that the rocket has come to rest on the ground after flight.
 *
 * Landed means: post-apogee flight stage, altitude back near the pad
 * reference, and near-zero vertical speed sustained for
 * CONFIG_LANDED_CONFIRM_MS. The confirm window is measured in the log-packet
 * time domain (time_boot_ms) so it behaves identically under HITL, where
 * acquire_sensor_data overwrites the packet timestamp.
 *
 * Latches g_rocket_landed once; never un-sets it. */
static void detect_landing(const AB_Filter &filter, uint32_t time_boot_ms)
{
  if (g_rocket_landed)
    return;

  static bool condition_active = false;
  static uint32_t condition_start_ms = 0;

  const bool post_apogee = filter.flight_stage == AB_Filter_Flight_Stage_APOGEE;
  const bool near_ground = filter.VertState.Altitude_m < CONFIG_LANDED_MAX_ALTITUDE_M;
  const bool still = fabsf(filter.VertState.VelocityUp_mps) < CONFIG_LANDED_MAX_VERTICAL_SPEED_MPS;

  if (post_apogee && near_ground && still)
  {
    if (!condition_active)
    {
      condition_active = true;
      condition_start_ms = time_boot_ms;
    }
    else if (time_boot_ms - condition_start_ms >= CONFIG_LANDED_CONFIRM_MS)
    {
      g_rocket_landed_tick = xTaskGetTickCount();
      g_rocket_landed = true;
      Serial.println("Landing detected");
    }
  }
  else
  {
    condition_active = false;
  }
}

static void runtime_task(void *pvParameters)
{
  // vTaskPreemptionDisable(NULL);

  /* Sample and average the altitude at flight computer startup and call it the ground altitude */
  constexpr int pressure_samples_for_ground_pressure = 20;
  float altitude_accumulator = 0;
  int valid_pressure_samples = 0;
  uint32_t last_time_boot_ms = 0;
  for (int i = 0; i < pressure_samples_for_ground_pressure; i++)
  {
    log_packet_latest log_p = get_blank_log_packet();
    acquire_sensor_data(&log_p);
    /* A failed/degraded barometer leaves pressure as NAN. Accumulating that would
       poison pad_altitude_m with NAN, which then poisons Barometer_m for the entire
       flight. Only average samples that produced a finite pressure reading. */
    if (isfinite(log_p.ms5607_pressure_mbar))
    {
      altitude_accumulator += get_altitude_from_pressure_pa(log_p.ms5607_pressure_mbar * 100);
      valid_pressure_samples++;
    }
    last_time_boot_ms = log_p.time_boot_ms;
    vTaskDelay(RUNTIME_INTERVAL_MS);
  }

  /* Fall back to 0 m (treat first baro reading as the reference) if no valid pad
     sample was obtained, rather than dividing by zero / propagating NAN. */
  const float pad_altitude_m = (valid_pressure_samples > 0)
                                   ? (altitude_accumulator / valid_pressure_samples)
                                   : 0.0f;

  AB_Filter filter;
  AB_Filter_Initialize(filter);

  TickType_t time = xTaskGetTickCount();
  TickType_t telemetry_timer = time;

  TickType_t loop_iter_time_us = 0;
  TickType_t loop_iter_time_max_us = 0;

  while (true)
  {
    instrumentation_reset();

    log_packet_latest log_p = get_blank_log_packet();
    log_p.status_flags = get_status_flags();
    log_p.time_boot_ms = xTaskGetTickCount();

    // Acquire step
    FSError sensor_acquire_status = acquire_sensor_data(&log_p);
    FSError gps_acquire_status = acquire_gps_data(&log_p);

    log_packet_make_header(&log_p); // This must be run after all other fields are set to be correct

    /* For HITL testing, acquire_sensor_data replaces log_p.time_boot_ms, so do
       delta time calculation based on the timestamp in the log packet. */
    const uint32_t delta_time_ms = log_p.time_boot_ms - last_time_boot_ms;
    last_time_boot_ms = log_p.time_boot_ms;

    AB_Filter_Inputs inputs;

    // Sensor axes, calibration, unit conversion — shared with pc-testing visualizer.
    log_packet_v3_fill_filter_inputs(log_p, inputs, pad_altitude_m);

    {
      float east_m, north_m, up_m, vel_east_mps, vel_north_mps;
      if (gps_compute_enu(log_p, &east_m, &north_m, &up_m, &vel_east_mps, &vel_north_mps))
      {
        inputs.GPS_Position_m  << east_m, north_m, up_m;
        /* No vertical GPS velocity available from NMEA; set to zero so the
           filter's vertical GPS update (guarded by z > 10 m/s) stays off. */
        inputs.GPS_Velocity_mps << vel_east_mps, vel_north_mps, 0.0f;
      }
      else
      {
        inputs.GPS_Position_m.setZero();
        inputs.GPS_Velocity_mps.setZero();
      }
    }

    /* We cannot use a fixed delta time in this code because OpenRocket
       refuses to give us fixed-size time steps for HITL testing.  */
    /* Guard the EKF timestep: a duplicate timestamp (dt == 0) or a non-monotonic
       / wrapped timestamp (huge unsigned delta) would otherwise destabilize the
       filter. Fall back to the nominal interval on a zero delta and clamp the
       upper bound to a physically sane step. */
    if (delta_time_ms == 0 || delta_time_ms > 1000)
    {
      inputs.dt = RUNTIME_INTERVAL_MS / 1000.0;
    }
    else
    {
      inputs.dt = delta_time_ms / 1000.0;
    }
    inputs.IgnoreBaro = false;

    AB_Filter_Process(filter, inputs, ab_settings);

    detect_landing(filter, log_p.time_boot_ms);

    xQueueSend(log_queue, &log_p, 0);

    /* Generate packet for airbrake deployment task and send it off */
    struct AirbrakesPacket airbrakes_packet{.ic = filter_to_apogee_ic(filter)};

    // PredictDeploymentAngle_print_params(airbrakes_packet.ic);
    // print_sensor_data(log_p);

    xQueueOverwrite(airbrakes_queue, &airbrakes_packet);

    /* Telemetry */
    if (time >= telemetry_timer)
    {
      telemetry_timer += TELEMETRY_INTERVAL_MS;

      telemetry_packet telemetry_p = fill_out_and_read_things_for_telemetry_packet(log_p, airbrakes_packet.ic.thetaZ_rad);
      telemetry_packet_make_header(&telemetry_p);

      LoRa.beginPacket();
      LoRa.write((uint8_t *)&telemetry_p, sizeof(telemetry_p));
      LoRa.endPacket(true);

      digitalWrite(PIN_ACTIVITY_LED, !digitalRead(PIN_ACTIVITY_LED));
    }

    loop_iter_time_us = instrumentation_get_microseconds();
    if (loop_iter_time_max_us < loop_iter_time_us)
    {
      loop_iter_time_max_us = loop_iter_time_us;
    }
    g_runtime_task_iter_us = loop_iter_time_us;
    g_runtime_task_iter_max_us = loop_iter_time_max_us;

    xTaskDelayUntil(&time, RUNTIME_INTERVAL_MS);
  }
}

static void deploy_task(void *pvParameters)
{
  static TickType_t time = xTaskGetTickCount();
  TickType_t loop_iter_time_us = 0;
  TickType_t loop_iter_time_max_us = 0;

  while (true)
  {
    instrumentation_reset();

    struct AirbrakesPacket airbrakes_packet_rx;

    BaseType_t receive_status = xQueueReceive(
        airbrakes_queue,
        &airbrakes_packet_rx,
        0);

    if (receive_status == pdTRUE)
    {
      int itersReqd;
      g_airbrake_pct = round(PredictDeploymentPct(airbrakes_packet_rx.ic, &itersReqd, ab_settings));
      const int servo_degrees = motor_map(g_airbrake_pct);

      AirBrakeServo.write(servo_degrees);

      // tone(PIN_BUZZER, 523, 25);

      // Serial.printf("dt: %d servo degrees: %d\n\r", delta_time, servo_degrees);
    }

    loop_iter_time_us = instrumentation_get_microseconds();
    if (loop_iter_time_max_us < loop_iter_time_us)
    {
      loop_iter_time_max_us = loop_iter_time_us;
    }
    g_deploy_task_iter_us = loop_iter_time_us;
    g_deploy_task_iter_max_us = loop_iter_time_max_us;

    xTaskDelayUntil(&time, DEPLOY_INTERVAL_MS);
  }
}

FSError do_servo_overcurrent_check()
{
  const int ADC_STEPS = (1 << int(ADC_RESOLUTION_BITS)) - 1;
  const float MAX_EXPECTED_VOLTAGE = 3.3;
  const int GAIN = 50;
  const float CSENSE_RESISTANCE = 0.01;

  const int csense_raw = analogRead(PIN_CSENSE);
  const float csense_voltage = ((float)csense_raw) / ADC_STEPS * MAX_EXPECTED_VOLTAGE;
  const float servo_current = csense_voltage / CSENSE_RESISTANCE / GAIN;
  // Serial.printf("Servo current: %f A\n\r", servo_current);

#define CURRENT_EMA_ALPHA 0.5
  // y[n]=αx[n]+(1−α)y[n−1]
  static float EMA_current_value = 0.0;
  EMA_current_value = CURRENT_EMA_ALPHA * servo_current + (1 - CURRENT_EMA_ALPHA) * EMA_current_value; // Exponential Moving Average
  g_servo_current_ma = (uint16_t)(EMA_current_value * 1000.0f);

  if (EMA_current_value > MAX_SERVO_CURRENT_AMPS)
  {
    // Cut current
    digitalWrite(PIN_ENABLE_AIRBRAKES, LOW);
    return SERVO_OVER_CURRENT;
  }

  return SUCCESS;
}

static void servo_overcurrent_task(void *pvParameters)
{
  static TickType_t time = 0;
  TickType_t loop_iter_time_us = 0;
  TickType_t loop_iter_time_max_us = 0;

  while (true)
  {
    instrumentation_reset();

    FSError overcurrent_status = do_servo_overcurrent_check();

    // Serial.printf("overcurrent status: %s\n\r", FS_ERROR_NAMES(overcurrent_status));

    loop_iter_time_us = instrumentation_get_microseconds();
    if (loop_iter_time_max_us < loop_iter_time_us)
    {
      loop_iter_time_max_us = loop_iter_time_us;
    }
    g_servo_overcurrent_task_iter_us = loop_iter_time_us;
    g_servo_overcurrent_task_iter_max_us = loop_iter_time_max_us;

    xTaskDelayUntil(&time, SERVO_OVERCURRENT_INTERVAL_MS); // runs at 100hz
  }
}

void gps_test_loop()
{
  gps_setup();

  while (true)
  {
    log_packet_latest log_p = {0};
    acquire_gps_data(&log_p);

    Serial.printf(
        "======== GPS data ========\n"
        "         gps_lat: %f deg\n"
        "         gps_lng: %f deg\n"
        "         gps_alt: %f m\n"
        "       gps_speed: %f\n"
        "      gps_course: %d\n"
        "    gps_num_sats: %d\n",
        log_p.gps_lat_deg,
        log_p.gps_lng_deg,
        log_p.gps_alt_m,
        log_p.gps_speed_mps,
        log_p.gps_course,
        log_p.gps_num_sats);

    delay(1000);
  }
}

static void sdcard_write_task(void *pvParameters)
{
  fs::File log_file;
  FSError log_status = sdcard_init(&log_file);
  if (log_status != SUCCESS)
  {
    sdcard_is_in_degraded_state = true;
    Serial.printf("[Error] SD Card Logging Initialization Failure: %s\n\r", FCError__strings[log_status]);
  }

  TickType_t loop_iter_time_us = 0;
  TickType_t loop_iter_time_max_us = 0;
  TickType_t last_flush_tick = xTaskGetTickCount();
  bool sdcard_shut_off = false;

  while (true)
  {
    log_packet_latest log_p;
    /* Bounded wait (instead of portMAX_DELAY) so the periodic flush and the
       post-landing shutoff below still run if log packets stop arriving. */
    const BaseType_t received = xQueueReceive(log_queue, &log_p, pdMS_TO_TICKS(CONFIG_SD_FLUSH_INTERVAL_MS));

    instrumentation_reset();

    const bool sd_writable = (log_status == SUCCESS) && !sdcard_shut_off;

    if (received == pdTRUE && sd_writable)
    {
      log_file.write((uint8_t *)&log_p, sizeof(log_packet_latest));
    }

    const TickType_t now = xTaskGetTickCount();

    /* Flush periodically so an abrupt power loss (hard landing, battery
       disconnect) costs at most CONFIG_SD_FLUSH_INTERVAL_MS of data. */
    if (sd_writable && now - last_flush_tick >= pdMS_TO_TICKS(CONFIG_SD_FLUSH_INTERVAL_MS))
    {
      log_file.flush();
      last_flush_tick = now;
    }

    /* Save the flight log and shut off the SD card a while after landing, so
       the filesystem is closed cleanly before recovery handling/power-off. */
    if (!sdcard_shut_off && g_rocket_landed &&
        now - g_rocket_landed_tick >= pdMS_TO_TICKS(CONFIG_SD_SHUTOFF_AFTER_LANDING_MS))
    {
      if (log_status == SUCCESS)
      {
        log_file.flush();
        log_file.close();
      }
      SD.end();
      sdcard_shut_off = true;
      Serial.println("[SD] Flight log saved and SD card shut off after landing");
      tone(PIN_BUZZER, 523, 500);
    }

    loop_iter_time_us = instrumentation_get_microseconds();
    if (loop_iter_time_max_us < loop_iter_time_us)
    {
      loop_iter_time_max_us = loop_iter_time_us;
    }
    g_sdcard_write_task_iter_us = loop_iter_time_us;
    g_sdcard_write_task_iter_max_us = loop_iter_time_max_us;
  }
}

static void lora_receive_packet_isr_callback(int packet_size);

static void lora_setup()
{
  LoRa.setSPI(SPI);
  LoRa.setPins(PIN_LORA_CS, PIN_LORA_RESET, PIN_LORA_IRQ_PIN0);
  if (!LoRa.begin(CONFIG_LORA_FREQUENCY_HZ_INITIAL))
  {
    Serial.println("LoRa initialization failed");
  }
  LoRa.setGain(6);
  LoRa.onReceive(lora_receive_packet_isr_callback);
}

/*
 * Verifies validity of received packet and pushes to receive queue if verified to be valid.
 */
static void lora_receive_packet_isr_callback(int packet_size)
{
  /* we don't need to check packet boundaries here because LoRa already has the idea of packets */

  // discard packets of the wrong size
  if (packet_size != sizeof(command_packet))
    return;

  /* read the received data into buffer */
  uint8_t buf[sizeof(command_packet)];
  for (int i = 0; i < sizeof(command_packet); i++)
  {
    int data_or_neg1 = LoRa.read();

    // if we run out of data while reading, return
    if (data_or_neg1 == -1)
      return;

    buf[i] = data_or_neg1;
  }

  command_packet p;
  memcpy(&p, buf, sizeof(command_packet));

  // if magic doesn't match, return
  if (memcmp(p.magic, COMMAND_PACKET_MAGIC, sizeof(p.magic)) != 0)
    return;

  // if "CMD" doesn't match, return
  if (memcmp(p.cmd, "CMD", sizeof(p.cmd)) != 0)
    return;

  /* verify CRC16 match */
  uint16_t p_crc16 = p.crc16;
  p.crc16 = 0;

  uint16_t computed_crc16 = crc_modbus((const unsigned char *)&p, sizeof(struct command_packet));
  // if CRC16 mismatch, return
  if (computed_crc16 != p_crc16)
    return;

  // if all checks pass, push verified command packet to queue
  xQueueSendFromISR(radio_command_rx_queue, &p, NULL);
}

void sensors_test_loop()
{
  FSError sensor_status = sensors_setup();
  if (sensor_status != SUCCESS)
  {
    while (true)
    {
      Serial.printf("[Error] Sensor Initialization Failure: %s\n\r", FCError__strings[sensor_status]);
    }
  }

  while (true)
  {
    log_packet_latest log_p = {
        .ms5607_pressure_mbar = NAN,
        .ms5607_temperature_c = NAN,
        .bmi323_accel_x_G = NAN, // LOW G
        .bmi323_accel_y_G = NAN,
        .bmi323_accel_z_G = NAN,
        .bmi323_gyro_x_degps = NAN,
        .bmi323_gyro_y_degps = NAN,
        .bmi323_gyro_z_degps = NAN,
        .adxl375_accel_x_G = NAN, // HIGH G
        .adxl375_accel_y_G = NAN,
        .adxl375_accel_z_G = NAN,
        .bm1422_magn_x = NAN,
        .bm1422_magn_y = NAN,
        .bm1422_magn_z = NAN,
    };

    FSError sensor_acquire_status = acquire_sensor_data(&log_p); // Should just work, but it doesn't

    print_sensor_data(log_p);

    delay(100);
  }
}

#ifdef CONFIG_TEST_ACCEL_CALIBRATION
void accel_calibration_test_loop()
{
  FSError sensor_status = sensors_setup();
  if (sensor_status != SUCCESS)
  {
    Serial.printf("[Error] Sensor init failure: %s\n\r", FCError__strings[sensor_status]);
  }

  SPI1.setMISO(PIN_FS_SPI_MISO);
  SPI1.setMOSI(PIN_FS_SPI_MOSI);
  SPI1.setSCK(PIN_FS_SPI_SCK);

  if (!SD.begin(PIN_SD_CS, SPI1))
  {
    Serial.println("[Error] SD card init failed");
    while (true)
      delay(1000);
  }

  const char *filename = "/accel_cal.csv";
  if (SD.exists(filename))
    SD.remove(filename);

  fs::File csv_file = SD.open(filename, FILE_WRITE);
  if (!csv_file)
  {
    Serial.println("[Error] Failed to open accel_cal.csv");
    while (true)
      delay(1000);
  }

  csv_file.println("capture_id,sample_id,bmi323_x_G,bmi323_y_G,bmi323_z_G,adxl375_x_G,adxl375_y_G,adxl375_z_G");
  csv_file.flush();

  Serial.println("Accel calibration mode. Press Enter to start each capture.");
  Serial.println("Suggested order: +X up, -X up, +Y up, -Y up, +Z up, -Z up");
  Serial.println("After 5s settling delay, 100 samples (1s at 100Hz) will be taken.");

  int capture_id = 0;
  while (true)
  {
    Serial.printf("Capture %d ready. Press Enter...\n\r", capture_id);

    while (Serial.read() == -1)
      delay(10);
    delay(20);
    while (Serial.available())
      Serial.read();

    Serial.printf("Capture %d: settling for 5 seconds...\n\r", capture_id);
    delay(5000);

    Serial.printf("Capture %d: sampling...\n\r", capture_id);
    for (int i = 0; i < 100; i++)
    {
      struct fc_adxl375_data adxl375_data = {};
      fc_adxl375_process(&adxl375, &adxl375_data);

      struct fc_bmi323_data bmi323_data = {};
      fc_bmi323_process(&bmi323, &bmi323_data);

      char line[128];
      snprintf(line, sizeof(line),
               "%d,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\r\n",
               capture_id, i,
               (double)bmi323_data.accel_x, (double)bmi323_data.accel_y, (double)bmi323_data.accel_z,
               (double)adxl375_data.accel_x, (double)adxl375_data.accel_y, (double)adxl375_data.accel_z);
      csv_file.print(line);

      delay(10);
    }

    csv_file.flush();
    Serial.printf("Capture %d complete.\n\r", capture_id);
    capture_id++;
  }
}
#endif

void test_airbrakes_algo_performance_loop()
{
  struct apogeeIC ic = {
      .altitude_m = 5000,
      .velocityZ_mps = 500, // around mach 1.5
      .thetaZ_rad = 80 * (M_PI / 180.0),
      .airbrakeDeployment_pct = 0.1,
  };

  while (true)
  {
    instrumentation_reset();

    // Run function to benchmark
    int itersReqd;
    const float airbrake_pct = PredictDeploymentPct(ic, &itersReqd, ab_settings);

    // Take time
    int us_taken = (int)instrumentation_get_microseconds();

    PredictDeploymentAngle_print_params(ic);
    Serial.printf("       airbrake_pct: %f\n", airbrake_pct);

    Serial.printf("       time taken: %d us\n", us_taken);
    Serial.printf("       iters reqd: %d\n", itersReqd);

    delay(100);
  }
}

void test_airbrakes_extend_and_retract_loop()
{
  airbrakes_setup();

  Serial.println("Entering airbrakes extend and retract test loop...");

  while (true)
  {
    int servo_degrees = AIRBRAKE_DEPLOYED_ANGLE;
    AirBrakeServo.write(servo_degrees);
    Serial.printf("Extend: %d degrees\n", servo_degrees);
    delay(2000);

    servo_degrees = AIRBRAKE_STOWED_ANGLE;
    AirBrakeServo.write(servo_degrees);
    Serial.printf("Retract: %d degrees\n", servo_degrees);
    delay(2000);
  }
}

void test_airbrakes_hitl_control_loop()
{
  airbrakes_setup();

  char buf[64];
  int buf_i = 0;
  while (true)
  {
    int data = Serial.read();
    if (data != -1)
    {
      if (buf_i < sizeof(buf) - 1)
      {
        buf[buf_i++] = data;
      }

      if (data == '\n')
      {
        buf[buf_i] = '\0';

        int pct = atoi(buf);

        Serial.println(pct);
        int servo_degrees = motor_map(pct);
        AirBrakeServo.write(servo_degrees);

        buf_i = 0;
      }
    }

    delay(10);
    do_servo_overcurrent_check();
  }
}

void pre_operational_mode_loop()
{
  Serial.println("Entering pre-operational mode. Waiting for SWITCH_TO_OPERATIONAL_MODE command from ground...");

  const TickType_t HEARTBEAT_INTERVAL_MS = 1000;
  TickType_t time = xTaskGetTickCount();
  TickType_t heartbeat_timer = time;

  while (true)
  {
    time = xTaskGetTickCount();

    /*
     * Received radio commands in radio_command_rx_queue have already been
     * verified (magic, "CMD", CRC16) by lora_receive_packet_isr_callback.
     */
    command_packet p;
    if (xQueueReceive(radio_command_rx_queue, &p, 0))
    {
      if (p.command_byte == RADIO_COMMAND_SWITCH_TO_OPERATIONAL_MODE)
      {
        Serial.println("SWITCH_TO_OPERATIONAL_MODE received. Entering operational mode.");
        break;
      }
      else if (p.command_byte == RADIO_COMMAND_DEPLOY_AIRBRAKES)
      {
        AirBrakeServo.write(motor_map(100));
      }
      else if (p.command_byte == RADIO_COMMAND_STOW_AIRBRAKES)
      {
        AirBrakeServo.write(motor_map(0));
      }
      else if (p.command_byte == RADIO_COMMAND_SET_LORA_FREQUENCY)
      {
        if (p.command_arg > CONFIG_LORA_FREQUENCY_HZ_MIN && p.command_arg < CONFIG_LORA_FREQUENCY_HZ_MAX)
        {
          LoRa.setFrequency(p.command_arg);
        }
      }
      else if (p.command_byte == RADIO_COMMAND_SET_LORA_BANDWIDTH)
      {
        /* Reject bandwidths below the usable minimum: shrinking the bandwidth too
           far degrades the link and could leave no way to command it back. */
        if (p.command_arg >= CONFIG_LORA_FREQUENCY_BANDWIDTH_HZ_MIN)
        {
          LoRa.setSignalBandwidth(p.command_arg);
        }
      }

      tone(PIN_BUZZER, 261, 70);
      delay(100);
      tone(PIN_BUZZER, 261, 70);
    }

    /* Heartbeat blip */
    tone(PIN_BUZZER, 1000, 10);

    log_packet_latest log_p = get_blank_log_packet();
    log_p.status_flags = get_status_flags();
    log_p.time_boot_ms = xTaskGetTickCount();

    // Acquire step
    FSError sensor_acquire_status = acquire_sensor_data(&log_p);
    FSError gps_acquire_status = acquire_gps_data(&log_p);

    telemetry_packet telemetry_p = fill_out_and_read_things_for_telemetry_packet(log_p, 0);
    telemetry_p.is_in_operational_mode = 0;
    telemetry_packet_make_header(&telemetry_p);

    LoRa.beginPacket();
    LoRa.write((uint8_t *)&telemetry_p, sizeof(telemetry_p));
    LoRa.endPacket(false);
    LoRa.receive();

    Serial.println("Pre-operational mode heartbeat");

    delay(1000);
  }

  tone(PIN_BUZZER, 261, 100);
  delay(100);
  tone(PIN_BUZZER, 523, 500);
}

void setup()
{
  // FLIGHT COMPUTER INITIALIZATION
  gpio_config();

  Serial.begin(921600);

  // No need to delay to allow for Serial connection if on PC
#ifndef __unix__
  tone(PIN_BUZZER, 523, 100);
  delay(3000);
  tone(PIN_BUZZER, 523, 100);
#endif

  STATIC_QUEUE_INIT_HELPER(airbrakes);
  STATIC_QUEUE_INIT_HELPER(log);
  STATIC_QUEUE_INIT_HELPER(radio_command_rx);

/* Make it very obvious, using a bunch of beeping, if a test option is enabled */
#ifdef CONFIG_TEST_ACTIVE
  for (int i = 0; i < 15; i++)
  {
    tone(PIN_BUZZER, 784, 100);
    delay(100);
  }
#endif

#ifdef CONFIG_TEST_GPS
  gps_test_loop();
#endif

#ifdef CONFIG_TEST_SENSORS
  sensors_test_loop();
#endif

#ifdef CONFIG_TEST_ACCEL_CALIBRATION
  accel_calibration_test_loop();
#endif

#ifdef CONFIG_TEST_AIRBRAKES_ALGO_PERFORMANCE
  test_airbrakes_algo_performance_loop();
#endif

#ifdef CONFIG_TEST_AIRBRAKES_EXTEND_AND_RETRACT
  test_airbrakes_extend_and_retract_loop();
#endif

#ifdef CONFIG_TEST_AIRBRAKES_HITL_CONTROL_ONLY
  test_airbrakes_hitl_control_loop();
#endif

  Serial.println("Setting up LoRa...");
  lora_setup();
  
  Serial.println("Setting up sensors...");
  // Sensors board
  FSError sensor_status = sensors_setup();
  if (sensor_status != SUCCESS)
  {
    Serial.printf("[Error] Sensor Initialization Failure: %s\n\r", FCError__strings[sensor_status]);
  }

  // Will not fly Pressure Transducer
  Serial.println("Setting up GPS...");
  gps_setup();

  Serial.println("Setting up airbrakes...");
  airbrakes_setup();

#ifndef CONFIG_TEST_NO_PRE_OPERATIONAL_MODE
  pre_operational_mode_loop();
#endif

  // FLIGHT COMPUTER RUNTIME

  BaseType_t runtime_task_status;
  TaskHandle_t runtime_task_handle;

  // runtime task
  runtime_task_status = xTaskCreate(runtime_task,
                                    "Runtime task",
                                    32768,
                                    NULL,
                                    configMAX_PRIORITIES - 1,
                                    &runtime_task_handle);

  if (runtime_task_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create runtime task");
    }
  }

  BaseType_t deploy_task_status;
  TaskHandle_t deploy_task_handle;

  // deploy task
  deploy_task_status = xTaskCreate(deploy_task,
                                   "Deploy task",
                                   32768,
                                   NULL,
                                   configMAX_PRIORITIES - 1,
                                   &deploy_task_handle);

  if (deploy_task_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create deploy task");
    }
  }

  // motor overcurrent task

  BaseType_t servo_overcurrent_task_status;
  TaskHandle_t servo_overcurrent_task_handle;

  servo_overcurrent_task_status = xTaskCreate(servo_overcurrent_task,
                                              "Servo overcurrent task",
                                              2048,
                                              NULL,
                                              configMAX_PRIORITIES - 1,
                                              &servo_overcurrent_task_handle);

  if (servo_overcurrent_task_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create servo overcurrent task");
    }
  }

  BaseType_t sdcard_write_task_status;
  TaskHandle_t sdcard_write_task_handle;

  sdcard_write_task_status = xTaskCreate(sdcard_write_task,
                                         "SD card write task",
                                         8192,
                                         NULL,
                                         configMAX_PRIORITIES - 2,
                                         &sdcard_write_task_handle);

  if (sdcard_write_task_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create SD card write task");
    }
  }

  Serial.printf("Operational mode entered. Tasks and Queues initialized...\n\r");

  // Keep the task alive
  while (true)
  {
    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
}

void loop()
{
  delay(100);
}
