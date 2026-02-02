#include <stdio.h>
#include <pico/stdlib.h>
#include <pico/binary_info.h>
#include <hardware/i2c.h>

#include <SPI.h>
#include <LoRa.h>
#include <SD.h>
#include <Wire.h>
#include <TinyGPS++.h>

#include "AltimeterFilter.h"
#include "sensors/adxl375.h"
#include "sensors/bm1422.h"
#include "sensors/bmi323.h"
#include "sensors/ms5607.h"

#include "pins.h"

#include "test_data.h"
#include "telemetry.h"


#define I2C_SENSOR_FREQUENCY 200000
#define LOG_INTERVAL_MS 10

const static TickType_t interval_ms = LOG_INTERVAL_MS; // 100 Hz

static fs::File log_file;

static struct fc_adxl375 adxl375;
static struct fc_bmi323 bmi323;
static struct fc_ms5607 ms5607;
static struct fc_bm1422 bm1422;

#define GPSSerial Serial2
static TinyGPSPlus gps;

/*
static bool sd_card_initialized_success = false;

static fs::File sdcard_and_logging_init()
{

  // Set up SD card

  // TODO: Maybe try re-opening the SD card if it disconnects mid-flight

  pinMode(ACTIVITY_PIN_LED, OUTPUT);
  if (SD.begin(PIN_SD_CS, SPI, 8000000))
  {
    Serial.println("SD card initialized!");
    sd_card_initialized_success = true;
    digitalWrite(ACTIVITY_PIN_LED, 1);
  }
  else
  {
    digitalWrite(ACTIVITY_PIN_LED, 0);
  }

  // Find a %d filename that is free to use
  char file_name[16];
  int file_num = 0;
  do
  {
    snprintf(file_name, 16, "/%d", file_num);
    file_num++;
  } while (SD.exists(file_name));

  // Open the file
  auto file = SD.open(file_name, FILE_WRITE, true);
  if (file)
  {
    Serial.print("Opened file \"");
    Serial.print(file_name);
    Serial.println("\" for telemetry logging\n");
  }
  else
  {
    Serial.print("Failed to open file \"");
    Serial.print(file_name);
    Serial.println("\" for telemetry logging\n");
  }

  return file;
}
*/


/// Due to the nature of the PICO we can configure
/// nearly every pin to do multiple functions.
/// As such all the pin configuration should
/// logically all be in one function.
static void gpio_config() {

  // sensor i2c configuration

  // The fact referring to the i2c busses is "Wire" and then "Wire1" is
  // objectively terrible design...
  // Unfortunately all the sensor drivers have already been written
  // so for now I won't be messing with this. - Diego

  setSDA(PIN_I2C0_SDA); // rppico specific
  setSCL(PIN_I2C0_SCL); // rppico specific
  Wire.begin();
  Wire.setClock(I2C_SENSOR_FREQUENCY);

  setSDA(PIN_I2C1_SDA); // rppico specific
  setSCL(PIN_I2C1_SCL); // rppico specific
  Wire1.begin();
  Wire1.setClock(I2C_SENSOR_FREQUENCY);
}

/// Maybe unnecessary, but gives peace of mind
static void gpio_deinit() {
  i2c_deinit(i2c0);
  i2c_deinit(i2c1);
}

static FSError sensors_setup()
{
  // Initialize sensor drivers
  FSError result = SUCCESS;

  bool retry = false;
  int num_retries = 0;

  do
  {
    if (result != SUCCESS) {
      Serial.printf("[Error] %i Retrying to initialize sensors...\n", num_retries);
    }

    result = SUCCESS;

    const FSError bm1422_status = fc_bm1422_initialize(&bm1422);
    const FSError adxl375_status = fc_adxl375_initialize(&adxl375);
    const FSError bmi323_status = fc_bmi323_initialize(&bmi323);
    const FSError ms5607_status = fc_ms5607_initialize(&ms5607);

    Serial.printf("bm1422 status: %s\n", bm1422_status);
    Serial.printf("adxl375 status: %s\n", adxl375_status);
    Serial.printf("bmi323 status: %s\n", bmi323_status);
    Serial.printf("ms5607 status: %s\n", ms5607_status);

    if (bm1422_status != SUCCESS) {
      result = bm1422_status;
    }

    if (adxl375_status != SUCCESS) {
      result = adxl375_status;
    }

    if (bmi323_status != SUCCESS) {
      result = bmi323_status;
    }

    if (ms5607_status != SUCCESS) {
      result = ms5607_status;
    }

  } while (result != SUCCESS && num_retries < 50);

  if (result != SUCCESS) {
    // TODO use an explicit output location instead of "Serial"
    Serial.printf("[Error] %s\n", FCErrors__strings[result]);
    result = SENSOR_INITIALIZATION_FAILURE;
  }

  return result;
}


/*void sd_setup()
{
  SPI.begin(PIN_SPI_CLK, PIN_SPI_MISO, PIN_SPI_MOSI);
  log_file = sdcard_and_logging_init();
}*/

/*
void lora_and_sd_setup()
{
  SPI.begin(7, 6, 5);
  LoRa.setSPI(SPI);
  LoRa.setPins(4, 18);
  LoRa.setTxPower(20);
  pinMode(ACTIVITY_PIN_LED, OUTPUT);
  while (!LoRa.begin(433E6))
  {
    delay(500);
    digitalWrite(ACTIVITY_PIN_LED, 1);
    delay(500);
    digitalWrite(ACTIVITY_PIN_LED, 0);
  }

  digitalWrite(ACTIVITY_PIN_LED, 1);
  delay(250);
  digitalWrite(ACTIVITY_PIN_LED, 0);
  delay(250);
  digitalWrite(ACTIVITY_PIN_LED, 1);

  LoRa.setSignalBandwidth(125E3);
  LoRa.setSpreadingFactor(12);
  LoRa.setPreambleLength(8);

  log_file = sdcard_and_logging_init();
}
*/

/*
void data_log_loop()
{
  TickType_t time = 0;
  Serial.println("Beginning data logging...");

  while (true)
  {
    // SEGGER_RTT_printf(0, "Sensor time (ms): %d\n", time);

    int start_ms = xTaskGetTickCount();
    struct fc_adxl375_data adxl375_data;
    fc_adxl375_process(&adxl375, &adxl375_data);

    struct fc_bm1422_data bm1422_data;
    fc_bm1422_process(&bm1422, &bm1422_data);

    struct fc_bmi323_data bmi323_data;
    fc_bmi323_process(&bmi323, &bmi323_data);

    struct fc_ms5607_data ms5607_data;
    fc_ms5607_process(&ms5607, &ms5607_data);
    int elapsed_ms = xTaskGetTickCount() - start_ms;

    // SEGGER_RTT_printf(0, "sensor process time: %d ms\n", elapsed_ms);

    uint8_t status_flags = 0;
    if (adxl375.is_in_degraded_state)
      status_flags |= STATUS_FLAGS_ADXL375_DEGRADED;
    if (bm1422.is_in_degraded_state)
      status_flags |= STATUS_FLAGS_BM1422_DEGRADED;
    if (bmi323.is_in_degraded_state)
      status_flags |= STATUS_FLAGS_BMI323_DEGRADED;
    if (ms5607.is_in_degraded_state)
      status_flags |= STATUS_FLAGS_MS5607_DEGRADED;

    struct log_packet_v3 log_p = {
        .status_flags = status_flags,
        .time_boot_ms = xTaskGetTickCount(),
        .ms5607_pressure_mbar = ms5607_data.pressure_mbar,
        .ms5607_temperature_c = ms5607_data.temperature_c,
        .bmi323_accel_x = bmi323_data.accel_x,
        .bmi323_accel_y = bmi323_data.accel_y,
        .bmi323_accel_z = bmi323_data.accel_z,
        .bmi323_gyro_x = bmi323_data.gyro_x,
        .bmi323_gyro_y = bmi323_data.gyro_y,
        .bmi323_gyro_z = bmi323_data.gyro_z,
        .adxl375_accel_x = adxl375_data.accel_x,
        .adxl375_accel_y = adxl375_data.accel_y,
        .adxl375_accel_z = adxl375_data.accel_z,
        .bm1422_magn_x = bm1422_data.magn_x,
        .bm1422_magn_y = bm1422_data.magn_y,
        .bm1422_magn_z = bm1422_data.magn_z,
        .gps_lat = NAN,
        .gps_lng = NAN,
        .gps_alt = NAN,
        .gps_speed = NAN,
        .gps_course = -0x7FFFFFFF,
        .gps_num_sats = 0xFF
    };

    while (GPSSerial.available())
    {
      gps.encode(GPSSerial.read());
    }

    if (gps.location.isValid())
    {
      log_p.gps_lat = gps.location.lat();
      log_p.gps_lng = gps.location.lng();
    }
    
    if (gps.altitude.isValid())
    {
      log_p.gps_alt = gps.altitude.meters();
    }
    
    if (gps.speed.isValid())
    {
      log_p.gps_speed = gps.speed.value();
    }
    
    if (gps.course.isValid())
    {
      log_p.gps_course = gps.course.value();
    }

    if (gps.satellites.isValid())
    {
      log_p.gps_num_sats = gps.satellites.value();
    }

    log_packet_make_header(&log_p);
    log_file.write((uint8_t *)&log_p, sizeof(log_p));
    log_file.flush();

    if (time % 1000 == 0)
    {
      if (sd_card_initialized_success)
      {
        digitalWrite(ACTIVITY_PIN_LED, !digitalRead(ACTIVITY_PIN_LED));
      }
      
      //Serial.print("Lat: ");
      //Serial.print(gps.location.lat(), 6);
      //Serial.print(" | Lon: ");
      //Serial.print(gps.location.lng(), 6);
      //Serial.print(" | Sats: ");
      //Serial.print(gps.satellites.value());
      //Serial.print(" | Alt: ");
      //Serial.print(gps.altitude.meters());
      //Serial.println(" m");
      
    }

    vTaskDelayUntil(&time, interval_ms);
  }
}
*/


/*
void gps_test_loop()
{
  TickType_t time = 0;
  Serial.println("Beginning GPS test and data logging...");

  while (1)
  {
    while (GPSSerial.available())
    {
      gps.encode(GPSSerial.read());
    }

    if (time % 1000 == 0)
    {
      Serial.print("Lat: ");
      Serial.print(gps.location.lat(), 6);
      Serial.print(" | Lon: ");
      Serial.print(gps.location.lng(), 6);
      Serial.print(" | Sats: ");
      Serial.print(gps.satellites.value());
      Serial.print(" | Alt: ");
      Serial.print(gps.altitude.meters());
      Serial.println(" m");
    }
    
    vTaskDelayUntil(&time, interval_ms);
  }
}
*/

// void airbrake_fake_data_test()
// {
//   int start_ms = xTaskGetTickCount();
//   TickType_t t;

//   int i = 0;
//   while (i < DATA_LEN && i < 2000)
//   {
//     auto pressure_mbar = ms5607_pressure_mbar[i];
//     auto accel_z_mps2 = adxl375_accel_z_mps2_fc_frame[i];
//     auto filter_out = airbrakes_process(pressure_mbar, accel_z_mps2);
//     airbrakes_check_for_retraction(filter_out);
//     xTaskDelayUntil(&t, 10);
//     if (i % 100 == 0)
//     {
//       Serial.println(i);
//     }
//     i++;
//   }

//   int end_ms = xTaskGetTickCount();

//   Serial.print("Completed 2000 iterations in ");
//   Serial.print(end_ms - start_ms);
//   Serial.println(" ms");
// }

void setup()
{
  Serial.printf("Hello world\n");

  gpio_config();

  //GPSSerial.begin(9600, SERIAL_8N1, PIN_GPS_RX, PIN_GPS_TX);

  //sd_setup();
  sensors_setup();

  //data_log_loop(); 
  gpio_deinit();
}

void loop()
{
  // ping_servo();

  // while (Serial1.available())
  // {
  // slip_read_byte(&slip, Serial1.read());
  // digitalWrite(PIN_LED, !digitalRead(PIN_LED));
  // }

  // LoRa.beginPacket();
  // LoRa.println("KF8EBM Hello World!");
  // Serial.println("KF8EBM Hello World!");
  // LoRa.endPacket();

  delay(100);
}
