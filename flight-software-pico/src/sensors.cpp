
#include "sensors/adxl375.h"
#include "sensors/bm1422.h"
#include "sensors/bmi323.h"
#include "sensors/ms5607.h"

#include "telemetry.h"

static struct fc_adxl375 adxl375;
static struct fc_bmi323 bmi323;
static struct fc_ms5607 ms5607;
static struct fc_bm1422 bm1422;

FSError sensors_setup()
{
  // Initialize sensor drivers
  FSError result = SUCCESS;

  // Magnometer is not in use because it barely helps the GNC and its a bitch to solder
  // const FSError bm1422_status = fc_bm1422_initialize(&bm1422);
  const FSError adxl375_status = fc_adxl375_initialize(&adxl375);
  const FSError bmi323_status = fc_bmi323_initialize(&bmi323);
  const FSError ms5607_status = fc_ms5607_initialize(&ms5607);

  // Serial.printf("[Info] bm1422 status: %s\n\r", FCError__strings[bm1422_status]);
  // Serial.printf("[Info] adxl375 status: %s\n\r", FCError__strings[adxl375_status]);
  // Serial.printf("[Info] bmi323 status: %s\n\r", FCError__strings[bmi323_status]);
  // Serial.printf("[Info] ms5607 status: %s\n\r", FCError__strings[ms5607_status]);

  // if (bm1422_status != SUCCESS) {
  // result = bm1422_status;
  // }

  if (adxl375_status != SUCCESS)
  {
    result = adxl375_status;
  }

  if (bmi323_status != SUCCESS)
  {
    result = bmi323_status;
  }

  if (ms5607_status != SUCCESS)
  {
    result = ms5607_status;
  }

  return result;
}

/// Acquires i2c sensor data and updates the provided log packet struct
/// If an error is encountered reading the data it provides it, but otherwise processes the data
FSError acquire_sensor_data(log_packet_latest *log_p)
{
#ifdef CONFIG_TEST_FULL_STACK_WITH_PRERECORDED_DATA
  return acquire_sensor_data_prerecorded(log_p);
#endif
#ifdef CONFIG_TEST_AIRBRAKES_HITL_FULL
  auto status = acquire_sensor_data_from_serial(log_p);
  // tone(PIN_BUZZER, 523, 100);
  /* Send airbrake deployment angle back to testing PC */
  Serial.write(g_airbrake_pct);
  return status;
#endif

  struct fc_adxl375_data adxl375_data;
  const FSError adxl_status = fc_adxl375_process(&adxl375, &adxl375_data);

  if (adxl_status == SUCCESS)
  {
    log_p->adxl375_accel_x_G = adxl375_data.accel_x;
    log_p->adxl375_accel_y_G = adxl375_data.accel_y;
    log_p->adxl375_accel_z_G = adxl375_data.accel_z;
  }
  else
  {
    // TODO maybe
  }

  // struct fc_bm1422_data bm1422_data;
  // const FSError bm1422_status = fc_bm1422_process(&bm1422, bm1422_data);

  // if (bm1422_status != SUCCESS) {
  //   // TODO maybe an error somewhere in the log
  //   // Serial.printf("bm1422 read error\n\r");
  //   return bm1422_status;
  // }

  struct fc_bmi323_data bmi323_data;
  const FSError bmi323_status = fc_bmi323_process(&bmi323, &bmi323_data);

  if (bmi323_status == SUCCESS)
  {
    log_p->bmi323_accel_x_G = bmi323_data.accel_x;
    log_p->bmi323_accel_y_G = bmi323_data.accel_y;
    log_p->bmi323_accel_z_G = bmi323_data.accel_z;
    log_p->bmi323_gyro_x_degps = bmi323_data.gyro_x;
    log_p->bmi323_gyro_y_degps = bmi323_data.gyro_y;
    log_p->bmi323_gyro_z_degps = bmi323_data.gyro_z;
  }
  else
  {
    // TODO maybe
  }

  struct fc_ms5607_data ms5607_data;
  const FSError ms5607_status = fc_ms5607_process(&ms5607, &ms5607_data);

  if (ms5607_status == SUCCESS)
  {
    log_p->ms5607_pressure_mbar = ms5607_data.pressure_mbar;
    log_p->ms5607_temperature_c = ms5607_data.temperature_c;
  }
  else
  {
    // TODO maybe
  }

  return SUCCESS;
}


/// TODO probably add more sensor state for PT and GPS or something
/// Produces a bitfield corresponding to which sensors are properly reading data
uint8_t get_sensor_status_flags()
{
  uint8_t result = 0;

  if (adxl375.is_in_degraded_state)
  {
    result |= STATUS_FLAGS_ADXL375_DEGRADED;
  }
  if (bm1422.is_in_degraded_state)
  {
    result |= STATUS_FLAGS_BM1422_DEGRADED;
  }
  if (bmi323.is_in_degraded_state)
  {
    result |= STATUS_FLAGS_BMI323_DEGRADED;
  }
  if (ms5607.is_in_degraded_state)
  {
    result |= STATUS_FLAGS_MS5607_DEGRADED;
  }

  return result;
}
