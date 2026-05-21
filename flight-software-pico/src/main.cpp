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
#include "sensors/adxl375.h"
#include "sensors/bm1422.h"
#include "sensors/bmi323.h"
#include "sensors/ms5607.h"
#include "pins.h"
#include "test_data.h"
#include "telemetry.h"
#include "logging.h"
#include <error.h>

// AirBrakes
#include "Filters/AB_Filter_Main.h"
#include "AB_Struct_Storage.h"
#include "AB_Deployment.h"

// Pico
#include <pico/stdlib.h>
#include <pico/binary_info.h>
#include <hardware/i2c.h>

// Arduino
#include <Servo.h>
#include <SPI.h>
#include <LoRa.h>
#include <SD.h>
#include <TinyGPS++.h>
#include <Wire.h>
#include <SPI.h>

// Adafruit
#include <Adafruit_ADS1X15.h>

// Flash
#include <WinbondW25N.h>

#include <RP2350.h>
#include "testing/testing.h"

#define I2C_SENSOR_FREQUENCY 200000
#define I2C_PRESSURE_TRANSDUCER_FREQUENCY 400000

#define GPS_BAUD_RATE 115200
#define GPS_UART_FIFO_SIZE 1024

#define MAX_SERVO_CURRENT_AMPS 2.2

#define ADC_RESOLUTION_BITS 12

// FreeRTOS tick is 1ms when using Arduino like this
// 20ms for 50hz, 10ms for 100hz, 4 for 250hz, 3 for 333.33hz, 2.5 for 400hz, 2 for 500hz
const static TickType_t runtime_interval_ms = CONFIG_RUNTIME_INTERVAL_MS; // 100 Hz
const static TickType_t servo_overcurrent_interval_ms = 10;               // 100 Hz
const static TickType_t deploy_interval_ms = 100;                          // 10 Hz
// const static TickType_t error_interval_ms = 100; // 10 Hz

FSError sdcard_init(fs::File *fileOut);

static fs::File log_file;

static struct fc_adxl375 adxl375;
static struct fc_bmi323 bmi323;
static struct fc_ms5607 ms5607;
static struct fc_bm1422 bm1422;


#define GPSSerial Serial1
static TinyGPSPlus gps;

static Adafruit_ADS1115 pt_ads;

#define AIRBRAKE_STOWED_ANGLE 91
#define AIRBRAKE_DEPLOYED_ANGLE 33
static Servo AirBrakeServo;
static uint8_t g_airbrake_pct = 0;

#define C5_HZ 587
#define NOTE(n) (C5_HZ * pow(2, (n / 12.0)))
#define BEEP(n) tone(PIN_BUZZER, NOTE(n), 100)

enum LogQueueType : uint8_t
{
  SENSOR,
  ERROR,
  DEPLOYMENT_ANGLE
};

struct LogQueue
{
  enum LogQueueType type;
  uint8_t error_code;
  int deployment_angle;
  uint8_t status_flags;       // StatusFlags bitfield
  uint32_t time_boot_ms;      // Timestamp (ms since system boot)
  float ms5607_pressure_mbar; // MS5607 Air Pressure (unit: mbar)
  float ms5607_temperature_c; // MS5607 Temperature (unit: degrees C)
  float bmi323_accel_x;       // BMI323 Acceleration X (unit: G)
  float bmi323_accel_y;       // BMI323 Acceleration Y (unit: G)
  float bmi323_accel_z;       // BMI323 Acceleration Z (unit: G)
  float bmi323_gyro_x;        // BMI323 Gyroscope X (unit: deg/s)
  float bmi323_gyro_y;        // BMI323 Gyroscope Y (unit: deg/s)
  float bmi323_gyro_z;        // BMI323 Gyroscope Z (unit: deg/s)
  float adxl375_accel_x;      // ADXL375 Acceleration X (unit: G)
  float adxl375_accel_y;      // ADXL375 Acceleration Y (unit: G)
  float adxl375_accel_z;      // ADXL375 Acceleration Z (unit: G)
  float bm1422_magn_x;        // BM1422 Magnetic Field X
  float bm1422_magn_y;        // BM1422 Magnetic Field Y
  float bm1422_magn_z;        // BM1422 Magnetic Field Z
  float gps_lat;              // Latitude  (unit: degres)
  float gps_lng;              // Longitude (unit: degrees)
  float gps_alt;              // Altitude  (unit: meters)
  float gps_speed;
  float pt_volts;
  int32_t gps_course;
  uint8_t gps_num_sats;
} LogQueue;

struct AirbrakesPacket
{
  struct apogeeIC ic;
} AirbrakesPacket;

static AB_Settings ab_settings = AB_Default_Settings();

const uint32_t airbrakes_queue_len = 10;
static StaticQueue_t airbrakes_queue_data;
uint8_t airbrakes_queue_storage_buffer[airbrakes_queue_len * sizeof(AirbrakesPacket)];
static QueueHandle_t airbrakes_queue;

const uint32_t log_queue_len = 100;
static StaticQueue_t log_queue_data;
uint8_t log_queue_storage_buffer[log_queue_len * sizeof(LogQueue)];
static QueueHandle_t log_queue;

/// Due to the nature of the PICO we can configure
/// nearly every pin to do multiple functions.
/// As such all the pin configuration should
/// logically all be in one function.
static void gpio_config()
{

  // sensor i2c configuration

  i2c_init(i2c0, I2C_SENSOR_FREQUENCY);
  gpio_set_function(PIN_I2C0_SDA, GPIO_FUNC_I2C);
  gpio_set_function(PIN_I2C0_SCL, GPIO_FUNC_I2C);
  gpio_pull_up(PIN_I2C0_SDA);
  gpio_pull_up(PIN_I2C0_SCL);

  pinMode(PIN_ACTIVITY_LED, OUTPUT);

  bi_decl(bi_2pins_with_func(PIN_I2C0_SDA, PIN_I2C0_SCL, GPIO_FUNC_I2C));
}

static FSError sensors_setup()
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

int motor_map(int pct)
{
  return map(pct, 0, 100, AIRBRAKE_STOWED_ANGLE, AIRBRAKE_DEPLOYED_ANGLE);
}

// static void print_log_packet(struct log_packet_v3 p) {
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

FSError acquire_gps_data(log_packet_v3 *log_p)
{
  while (GPSSerial.available())
  {
    uint8_t c = GPSSerial.read();
    gps.encode(c);
#ifdef CONFIG_TEST_GPS_PRINT_NMEA_TO_SERIAL
    Serial.print((char)c);
#endif
  }

  if (gps.location.isValid())
  {
    log_p->gps_lat_deg = gps.location.lat();
    log_p->gps_lng_deg = gps.location.lng();
  }

  if (gps.altitude.isValid())
  {
    log_p->gps_alt_m = gps.altitude.meters();
  }

  if (gps.speed.isValid())
  {
    log_p->gps_speed_mps = gps.speed.value();
  }

  if (gps.course.isValid())
  {
    log_p->gps_course = gps.course.value();
  }

  if (gps.satellites.isValid())
  {
    log_p->gps_num_sats = gps.satellites.value();
  }

  return SUCCESS; // add gps knockout????? errror
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

/// Acquires i2c sensor data and updates the provided log packet struct
/// If an error is encountered reading the data it provides it, but otherwise processes the data
FSError acquire_sensor_data(struct log_packet_v3 *log_p)
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

  if (adxl_status != SUCCESS)
  {
    // TODO maybe an error somewhere in the log
    return adxl_status;
    // Serial.printf("adxl read error\n\r");
  }
  else
  {
    log_p->adxl375_accel_x_G = adxl375_data.accel_x;
    log_p->adxl375_accel_y_G = adxl375_data.accel_y;
    log_p->adxl375_accel_z_G = adxl375_data.accel_z;
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

  if (bmi323_status != SUCCESS)
  {
    // TODO maybe an error somewhere in the log
    // Serial.printf("bmi323 read error\n\r");
    return bmi323_status;
  }
  else
  {
    log_p->bmi323_accel_x_G = bmi323_data.accel_x;
    log_p->bmi323_accel_y_G = bmi323_data.accel_y;
    log_p->bmi323_accel_z_G = bmi323_data.accel_z;
    log_p->bmi323_gyro_x_degps = bmi323_data.gyro_x;
    log_p->bmi323_gyro_y_degps = bmi323_data.gyro_y;
    log_p->bmi323_gyro_z_degps = bmi323_data.gyro_z;
  }

  struct fc_ms5607_data ms5607_data;
  const FSError ms5607_status = fc_ms5607_process(&ms5607, &ms5607_data);

  if (ms5607_status != SUCCESS)
  {
    // TODO maybe an error somewhere in the log
    // Serial.printf("ms5607 read error\n\r");
    return ms5607_status;
  }
  else
  {
    log_p->ms5607_pressure_mbar = ms5607_data.pressure_mbar;
    log_p->ms5607_temperature_c = ms5607_data.temperature_c;
  }

  return SUCCESS;
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

  if (EMA_current_value > MAX_SERVO_CURRENT_AMPS)
  {
    // Cut current
    digitalWrite(PIN_ENABLE_AIRBRAKES, LOW);
    return SERVO_OVER_CURRENT;
  }

  return SUCCESS;
}

void print_sensor_data(const log_packet_v3 &log_p)
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

static log_packet_v3 get_blank_log_packet()
{
  struct log_packet_v3 log_p = {
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

static void runtime_task(void *pvParameters)
{
  static TickType_t time = xTaskGetTickCount();
  
  /* Sample and average the altitude at flight computer startup and call it the ground altitude */
  constexpr int pressure_samples_for_ground_pressure = 20;
  float altitude_accumulator = 0;
  for (int i = 0; i < pressure_samples_for_ground_pressure; i++)
  {
    log_packet_v3 log_p = get_blank_log_packet();
    acquire_sensor_data(&log_p);
    altitude_accumulator += get_altitude_from_pressure_pa(log_p.ms5607_pressure_mbar * 100);
    vTaskDelay(runtime_interval_ms);
  }
  
  const float pad_altitude_m = altitude_accumulator / pressure_samples_for_ground_pressure;
  
  AB_Filter filter;
  AB_Filter_Initialize(filter);
  
  while (true)
  {
    const TickType_t current_time = xTaskGetTickCount();
    const TickType_t delta_time = current_time - time;
    const float delta_time_float = portTICK_PERIOD_MS / delta_time;
    time = current_time;
    
    log_packet_v3 log_p = get_blank_log_packet();
    log_p.status_flags = get_sensor_status_flags();
    log_p.time_boot_ms = time;
    
    // Acquire step
    FSError sensor_acquire_status = acquire_sensor_data(&log_p);
    FSError gps_acquire_status = acquire_gps_data(&log_p);
    
    log_packet_make_header(&log_p); // This must be run last for CRC to be correct
    
    AB_Filter_Inputs inputs;
    
    // Convert log packet into airbrake filter inputs
    inputs.Accelerometer_mps2 <<     log_p.bmi323_accel_y_G * G_CONST,
                                     log_p.bmi323_accel_x_G * G_CONST, 
                                     log_p.bmi323_accel_z_G * G_CONST;
    inputs.AccelerometerHG_mps2 <<  -log_p.adxl375_accel_x_G * G_CONST, 
                                    -log_p.adxl375_accel_y_G * G_CONST,
                                     log_p.adxl375_accel_z_G * G_CONST;
    inputs.Gyroscope_radps << log_p.bmi323_gyro_x_degps * (M_PI / 180.0f),
                              log_p.bmi323_gyro_y_degps * (M_PI / 180.0f),
                              log_p.bmi323_gyro_z_degps * (M_PI / 180.0f);
    inputs.Magnetometer.setZero();
    inputs.GPS_Position_m.setZero();
    inputs.GPS_Velocity_mps.setZero();
    float current_abs_alt = get_altitude_from_pressure_pa(log_p.ms5607_pressure_mbar * 100.0f);
    // inputs.Barometer_m = current_abs_alt - pad_altitude_m;
    inputs.Barometer_m = current_abs_alt;
    inputs.dt = runtime_interval_ms / 1000.0; 
    inputs.IgnoreBaro = false;
    
    // TODO: GPS integration
    
    AB_Filter_Process(filter, inputs, ab_settings);
    
    log_file.write((uint8_t *)&log_p, sizeof(log_packet_v3));
    log_file.flush();
  
    /* Generate packet for airbrake deployment task and send it off */
    float velocityHoriz_mps = sqrt(filter.HorizState.VelocityNorth_mps * filter.HorizState.VelocityNorth_mps +
                    filter.HorizState.VelocityEast_mps * filter.HorizState.VelocityEast_mps);
    struct AirbrakesPacket airbrakes_packet{.ic = 
      {
        .altitude_m = filter.VertState.Altitude_m,
        .velocityZ_mps = filter.VertState.VelocityUp_mps,
        .thetaZ_rad = (float)(atan2(velocityHoriz_mps, filter.VertState.VelocityUp_mps)),
        .airbrakeDeployment_pct = 0,
    }};

    // PredictDeploymentAngle_print_params(airbrakes_packet.ic);
    // print_sensor_data(log_p);

    xQueueSendToFront(
        airbrakes_queue,
        &airbrakes_packet,
        0);

    xTaskDelayUntil(&time, runtime_interval_ms);
  }
}


static void deploy_task(void *pvParameters)
{
  static TickType_t time = xTaskGetTickCount();

  while (true)
  {
    const TickType_t current_time = xTaskGetTickCount();
    const TickType_t delta_time = current_time - time;
    // const float delta_time_float = portTICK_PERIOD_MS / delta_time;
    time = current_time;

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

      xQueueReset(airbrakes_queue);
    }

    xTaskDelayUntil(&time, deploy_interval_ms); // TODO log deployed angle
  }
}

static void servo_overcurrent_task(void *pvParameters)
{
  static TickType_t time = 0;
  while (true)
  {
    FSError overcurrent_status = do_servo_overcurrent_check();

    // Serial.printf("overcurrent status: %s\n\r", FS_ERROR_NAMES(overcurrent_status));

    xTaskDelayUntil(&time, servo_overcurrent_interval_ms); // runs at 100hz
  }
}

void gps_setup()
{
  GPSSerial.setRX(PIN_GPS_RX);
  GPSSerial.setTX(PIN_GPS_TX);
  GPSSerial.setFIFOSize(GPS_UART_FIFO_SIZE);
  GPSSerial.begin(GPS_BAUD_RATE, SERIAL_8N1);
}

void gps_test_loop()
{
  gps_setup();

  while (true)
  {
    log_packet_v3 log_p = {0};
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
    log_packet_v3 log_p = {
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

void pressure_transducer_setup()
{
  Serial.println("Setting up PT...");
  pt_ads.begin(0x48, &Wire1, PIN_I2C1_SDA, PIN_I2C1_SCL);
}

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
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    // Reset and enable the cycle counter
    DWT->CYCCNT = 0;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;

    // Run function to benchmark
    int itersReqd;
    const float airbrake_pct = PredictDeploymentPct(ic, &itersReqd, ab_settings);

    // Take time
    int us_taken = DWT->CYCCNT / SYS_CLK_MHZ;

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

void setup()
{
  // FLIGHT COMPUTER INITIALIZATION
  gpio_config();

  Serial.begin(921600);

  tone(PIN_BUZZER, 523, 100);
  delay(3000);
  tone(PIN_BUZZER, 523, 100);

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

#ifdef CONFIG_TEST_AIRBRAKES_ALGO_PERFORMANCE
  test_airbrakes_algo_performance_loop();
#endif

#ifdef CONFIG_TEST_AIRBRAKES_EXTEND_AND_RETRACT
  test_airbrakes_extend_and_retract_loop();
#endif

#ifdef CONFIG_TEST_AIRBRAKES_HITL_CONTROL_ONLY
  test_airbrakes_hitl_control_loop();
#endif

  /* SD card and flash logging */
  Serial.println("Setting up SD card...");
  FSError log_status = sdcard_init(&log_file);
  if (log_status != SUCCESS)
  {
    Serial.printf("[Error] SD Card Logging Initialization Failure: %s\n\r", FCError__strings[log_status]);
  }

  Serial.println("Setting up sensors...");
  // Sensors board
  FSError sensor_status = sensors_setup();
  if (sensor_status != SUCCESS)
  {
    Serial.printf("[Error] Sensor Initialization Failure: %s\n\r", FCError__strings[sensor_status]);
  }

  // Pressure Transducer

  // GPS ?
  gps_setup();

  Serial.println("Setting up airbrakes...");
  airbrakes_setup();

  airbrakes_queue = xQueueCreateStatic(
      airbrakes_queue_len,
      sizeof(AirbrakesPacket),
      airbrakes_queue_storage_buffer,
      &airbrakes_queue_data);

  log_queue = xQueueCreateStatic(
      log_queue_len,
      sizeof(LogQueue),
      log_queue_storage_buffer,
      &log_queue_data);

  // FLIGHT COMPUTER RUNTIME

  BaseType_t runtime_status;
  TaskHandle_t runtime_handle;

  // runtime task
  runtime_status = xTaskCreate(runtime_task,
                               "Runtime task",
                               32768,
                               NULL,
                               configMAX_PRIORITIES - 1,
                               &runtime_handle);

  if (runtime_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create runtime task");
    }
  }

  BaseType_t deploy_status;
  TaskHandle_t deploy_handle;

  // deploy task
  deploy_status = xTaskCreate(deploy_task,
                              "Deploy task",
                              32768,
                              NULL,
                              configMAX_PRIORITIES - 1,
                              &deploy_handle);

  if (deploy_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create deploy task");
    }
  }

  // motor overcurrent task

  BaseType_t servo_overcurrent_status;
  TaskHandle_t servo_overcurrent_handle;

  servo_overcurrent_status = xTaskCreate(servo_overcurrent_task,
                                         "Servo overcurrent task",
                                         2048,
                                         NULL,
                                         configMAX_PRIORITIES - 1,
                                         &servo_overcurrent_handle);

  if (servo_overcurrent_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create servo overcurrent task");
    }
  }

  Serial.printf("Tasks and Queues initialized...\n\r");

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
