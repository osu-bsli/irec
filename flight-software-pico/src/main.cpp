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
const static TickType_t runtime_interval_ms = 10; // 100 Hz
const static TickType_t moc_interval_ms = 10;     // 100 Hz
const static TickType_t deploy_interval_ms = 20;  // 50 Hz
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
Servo AirBrakeServo;

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

struct AcquirePacket
{
  struct apogeeIC ic;
} AcquirePacket;

const uint32_t acquire_queue_len = 10;
static StaticQueue_t acquire_queue_data;
uint8_t acquire_queue_storage_buffer[acquire_queue_len * sizeof(AcquirePacket)];
static QueueHandle_t acquire_queue;

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

int motor_map(float value)
{
  int size = AIRBRAKE_STOWED_ANGLE - AIRBRAKE_DEPLOYED_ANGLE;

  int result = AIRBRAKE_STOWED_ANGLE + size * value;

  if (result > AIRBRAKE_STOWED_ANGLE)
  {
    result = AIRBRAKE_STOWED_ANGLE;
  }
  if (result < AIRBRAKE_DEPLOYED_ANGLE)
  {
    result = AIRBRAKE_DEPLOYED_ANGLE;
  }

  return result;
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
    log_p->gps_lat = gps.location.lat();
    log_p->gps_lng = gps.location.lng();
  }

  if (gps.altitude.isValid())
  {
    log_p->gps_alt = gps.altitude.meters();
  }

  if (gps.speed.isValid())
  {
    log_p->gps_speed = gps.speed.value();
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
uint8_t get_sensor_state()
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
    log_p->adxl375_accel_x = adxl375_data.accel_x;
    log_p->adxl375_accel_y = adxl375_data.accel_y;
    log_p->adxl375_accel_z = adxl375_data.accel_z;
  }

  // struct fc_bm1422_data bm1422_data;
  // const FSError bm1422_status = fc_bm1422_process(&bm1422, bm1422_data);

  // if (bm1422_status != SUCCESS) {
  //   // TODO maybe an error somewhere in the log
  //   // Serial.printf("bmi323 read error\n\r");
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
    log_p->bmi323_accel_x = bmi323_data.accel_x;
    log_p->bmi323_accel_y = bmi323_data.accel_y;
    log_p->bmi323_accel_z = bmi323_data.accel_z;
    log_p->bmi323_gyro_x = bmi323_data.gyro_x;
    log_p->bmi323_gyro_y = bmi323_data.gyro_y;
    log_p->bmi323_gyro_z = bmi323_data.gyro_z;
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

void init_airbrakes()
{
  // Allow current to the air brakes
  pinMode(PIN_ENABLE_AIRBRAKES, OUTPUT);
  digitalWrite(PIN_ENABLE_AIRBRAKES, HIGH);

  AirBrakeServo.attach(PIN_AIRBRAKES_TX, 900, 2100);

  // Current sense setup
  analogReadResolution(ADC_RESOLUTION_BITS);
}

FSError servo_overcurrent()
{
  const int ADC_STEPS = (1 << int(ADC_RESOLUTION_BITS)) - 1;
  const float MAX_EXPECTED_VOLTAGE = 3.3;
  const int GAIN = 50;
  const float CSENSE_RESISTANCE = 0.01;

  const int csense_raw = analogRead(PIN_CSENSE);
  const float csense_voltage = ((float)csense_raw) / ADC_STEPS * MAX_EXPECTED_VOLTAGE;
  const float servo_current = csense_voltage / CSENSE_RESISTANCE / GAIN;
  // Serial.printf("%d %fV %fA\n\r", csense_raw, csense_voltage, servo_current);

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

const float SEA_LEVEL_PRESSURE_PA = 101325.0f;
float get_altitude_from_pressure(float pressure_pa)
{
  if (pressure_pa < 0.1f)
    return 0.0f;
  return 44330.0f * (1.0f - std::pow(pressure_pa / SEA_LEVEL_PRESSURE_PA, 1.0f / 5.255f));
}

static void runtime(void *pvParameters)
{
  static TickType_t time = xTaskGetTickCount();

  struct apogeeIC ic = {0};
  AB_Filter_Main_Variables M;

  float pressures[5] = {0.0};
  fc_ms5607_data pressure_init_data;
  for (int i = 0; i < 5; i++)
  {
    fc_ms5607_process(&ms5607, &pressure_init_data);
    pressures[i] = get_altitude_from_pressure(pressure_init_data.pressure_mbar * 100);
  }

  static float base_altitude = pressures[0] + pressures[1] + pressures[2] + pressures[3] + pressures[4] / 5; // average of the first 5 values

  AB_Filter_Initialize(M);

  while (true)
  {
    const TickType_t current_time = xTaskGetTickCount();
    const TickType_t delta_time = current_time - time;
    const float delta_time_float = portTICK_PERIOD_MS / delta_time;
    time = current_time;

    struct log_packet_v3 log_p = {
        .status_flags = get_sensor_state(),
        .time_boot_ms = time,
        .ms5607_pressure_mbar = NAN,
        .ms5607_temperature_c = NAN,
        .bmi323_accel_x = NAN, // LOW G
        .bmi323_accel_y = NAN,
        .bmi323_accel_z = NAN,
        .bmi323_gyro_x = NAN,
        .bmi323_gyro_y = NAN,
        .bmi323_gyro_z = NAN,
        .adxl375_accel_x = NAN, // HIGH G
        .adxl375_accel_y = NAN,
        .adxl375_accel_z = NAN,
        .bm1422_magn_x = NAN,
        .bm1422_magn_y = NAN,
        .bm1422_magn_z = NAN,
        .gps_lat = NAN,
        .gps_lng = NAN,
        .gps_alt = NAN,
        .gps_speed = NAN,
        .pt_volts = NAN,
        .gps_course = -0x7FFFFFFF,
        .gps_num_sats = 0xFF,
    };

    // Acquire step

    FSError sensor_acquire_status = acquire_sensor_data(&log_p); // Should just work, but it doesn't
    FSError gps_acquire_status = acquire_gps_data(&log_p);

    log_packet_make_header(&log_p); // This must be run last for CRC to be correct

    // print_log_packet(log_p); // THIS FUNCTION FUCKING SUCKS
    Serial.printf("time: %u %u %u\n\r", xTaskGetTickCount(), time, log_p.time_boot_ms);
    // Serial.printf("flags: %u\n\r", log_p.status_flags);
    // Serial.printf("%f %f %f", log_p.bmi323_accel_x, log_p.bmi323_accel_y, log_p.bmi323_accel_z);
    // Serial.printf(" %f %f %f\n\r", log_p.bmi323_gyro_x, log_p.bmi323_gyro_y, log_p.bmi323_gyro_z);
    // Serial.printf("pressure: %f\n\r", log_p.ms5607_pressure_mbar);
    // Serial.printf("%f %f %f\n\r", log_p.adxl375_accel_x, log_p.adxl375_accel_y, log_p.adxl375_accel_z);

    // Control systems

    // TODO switch to microseconds for dt
    // Calculate dt using previous point
    float dt = delta_time_float / 1000.0f; // ms to s
    if (dt <= 0.0f)
      dt = 0.001f;
    M.Sensors.dt = dt;

    // Update sensor data in Master Struct
    M.Sensors.Accelerometer << log_p.bmi323_accel_y, log_p.bmi323_accel_x, -log_p.bmi323_accel_z;
    M.Sensors.AccelerometerHG << -log_p.adxl375_accel_x, -log_p.adxl375_accel_y, log_p.adxl375_accel_z;
    M.Sensors.Gyroscope << log_p.bmi323_gyro_x * (M_PI / 180.0f),
        log_p.bmi323_gyro_y * (M_PI / 180.0f),
        log_p.bmi323_gyro_z * (M_PI / 180.0f);
    M.Sensors.Barometer = get_altitude_from_pressure(log_p.ms5607_pressure_mbar * 100) + base_altitude;
    M.Sensors.GPS.setZero();

    AB_loop(M);

    const float v_horiz = sqrt(M.HorizState.Velocity_North * M.HorizState.Velocity_North +
                               M.HorizState.Velocity_East * M.HorizState.Velocity_East);
    const float zenith_deg = atan2(v_horiz, M.VertState.Velocity_Up) * RAD_TO_DEG;

    ic.positionZ = M.VertState.Altitude;
    ic.velocityZ = M.VertState.Velocity_Up;
    ic.thetaZRad = zenith_deg;

    // log_file.write((uint8_t *) &log_p, sizeof(log_packet_v3));
    // log_file.flush();

    struct AcquirePacket acquire_packet{.ic = ic};

    xQueueSendToFront(
        acquire_queue,
        &acquire_packet,
        0);

    xTaskDelayUntil(&time, runtime_interval_ms);
    
    // Serial.printf("dt: %u target: %u acquire: %u filter: %u motor time: %u motor deploy: %f\n\r", delta_time, interval_ms, acquire_time, gnc_time, motor_time, airbrake_pct);
  }
}

static void deploy(void *pvParameters)
{
  static TickType_t time = xTaskGetTickCount();

  while (true)
  {
    const TickType_t current_time = xTaskGetTickCount();
    const TickType_t delta_time = current_time - time;
    // const float delta_time_float = portTICK_PERIOD_MS / delta_time;
    time = current_time;

    struct AcquirePacket acquire_packet;

    BaseType_t receive_status = xQueueReceive(
        acquire_queue,
        &acquire_packet,
        0);

    if (receive_status != pdPASS)
    {
      Serial.printf("receive failure\n\r");
    }

    const float airbrake_pct = PredictDeploymentAngle(&acquire_packet.ic, CONFIG_AIRBRAKES_TARGET_APOGEE_METERS);
    const int servo_degrees = motor_map(airbrake_pct);

    AirBrakeServo.write(servo_degrees);

    // Serial.printf("dt: %d servo degrees: %d\n\r", delta_time, servo_degrees);
    Serial.printf("======== PredictDeploymentAngle parameters =========\n");
    Serial.printf("          positionZ: %f\n", acquire_packet.ic.positionZ);
    Serial.printf("          velocityZ: %f\n", acquire_packet.ic.velocityZ);
    Serial.printf("             thetaZ: %f\n", acquire_packet.ic.thetaZRad);
    Serial.printf("    deploymentAngle: %f\n", acquire_packet.ic.deploymentAngle);

    xTaskDelayUntil(&time, deploy_interval_ms); // TODO log deployed angle
  }
}

static void moc_task(void *pvParameters)
{
  static TickType_t time = 0;
  while (true)
  {
    FSError overcurrent_status = servo_overcurrent();

    // Serial.printf("overcurrent status: %s\n\r", FS_ERROR_NAMES(overcurrent_status));

    xTaskDelayUntil(&time, moc_interval_ms); // runs at 100hz
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
        log_p.gps_lat,
        log_p.gps_lng,
        log_p.gps_alt,
        log_p.gps_speed,
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
        .bmi323_accel_x = NAN, // LOW G
        .bmi323_accel_y = NAN,
        .bmi323_accel_z = NAN,
        .bmi323_gyro_x = NAN,
        .bmi323_gyro_y = NAN,
        .bmi323_gyro_z = NAN,
        .adxl375_accel_x = NAN, // HIGH G
        .adxl375_accel_y = NAN,
        .adxl375_accel_z = NAN,
        .bm1422_magn_x = NAN,
        .bm1422_magn_y = NAN,
        .bm1422_magn_z = NAN,
    };

    FSError sensor_acquire_status = acquire_sensor_data(&log_p); // Should just work, but it doesn't

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
        log_p.bmi323_accel_x,
        log_p.bmi323_accel_y,
        log_p.bmi323_accel_z,
        log_p.bmi323_gyro_x,
        log_p.bmi323_gyro_y,
        log_p.bmi323_gyro_z,
        log_p.adxl375_accel_x,
        log_p.adxl375_accel_y,
        log_p.adxl375_accel_z,
        log_p.bm1422_magn_x,
        log_p.bm1422_magn_y,
        log_p.bm1422_magn_z);

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
      .positionZ = 5000,
      .velocityZ = 500, // around mach 1.5
      .thetaZRad = 80 * (M_PI / 180.0),
      .deploymentAngle = 0.1,
  };

  while (true)
  {
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    // Reset and enable the cycle counter
    DWT->CYCCNT = 0;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;

    // Run function to benchmark
    const float airbrake_pct = PredictDeploymentAngle(&ic, CONFIG_AIRBRAKES_TARGET_APOGEE_METERS);

    // Take time
    int us_taken = DWT->CYCCNT / SYS_CLK_MHZ;

    Serial.printf("======== PredictDeploymentAngle parameters =========\n");
    Serial.printf("          positionZ: %f\n", ic.positionZ);
    Serial.printf("          velocityZ: %f\n", ic.velocityZ);
    Serial.printf("          thetaZRad: %f\n", ic.thetaZRad);
    Serial.printf("    deploymentAngle: %f\n", ic.deploymentAngle);
    // Serial.println();
    Serial.printf("       airbrake_pct: %f\n", airbrake_pct);
    // Serial.println();

    // convert cycles to microseconds assuming 150 MHz clock

    Serial.printf("       time taken: %d us\n", us_taken);

    delay(100);
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
  init_airbrakes();

  acquire_queue = xQueueCreateStatic(
      acquire_queue_len,
      sizeof(AcquirePacket),
      acquire_queue_storage_buffer,
      &acquire_queue_data);

  log_queue = xQueueCreateStatic(
      log_queue_len,
      sizeof(LogQueue),
      log_queue_storage_buffer,
      &log_queue_data);

  // FLIGHT COMPUTER RUNTIME

  BaseType_t runtime_status;
  TaskHandle_t runtime_handle;

  // runtime task
  runtime_status = xTaskCreate(runtime,
                               "Acquire",
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

  /*
  // deploy task
  deploy_status = xTaskCreate(deploy,
                              "Deploy",
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
  */

  // motor overcurrent task

  BaseType_t moc_status;
  TaskHandle_t moc_handle;

  moc_status = xTaskCreate(moc_task,
                           "Motor Overcurrent",
                           2048,
                           NULL,
                           configMAX_PRIORITIES - 1,
                           &moc_handle);

  if (moc_status != pdPASS)
  {
    while (true)
    {
      Serial.printf("[Error] Could not create motor overcurrent task");
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
