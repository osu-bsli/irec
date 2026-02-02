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
#include "web_panel.h"


#define LOG_INTERVAL_MS 10

const static TickType_t interval_ms = LOG_INTERVAL_MS; // 100 Hz

static fs::File log_file;

static struct fc_adxl375 adxl375;
static struct fc_bmi323 bmi323;
static struct fc_ms5607 ms5607;
static struct fc_bm1422 bm1422;

#define GPSSerial Serial2
static TinyGPSPlus gps;

static bool sd_card_initialized_success = false;

static fs::File sdcard_and_logging_init()
{

  /* Set up SD card */

  // TODO: Maybe try re-opening the SD card if it disconnects mid-flight

  pinMode(PIN_LED, OUTPUT);
  if (SD.begin(PIN_SD_CS, SPI, 8000000))
  {
    Serial.println("SD card initialized!");
    sd_card_initialized_success = true;
    digitalWrite(PIN_LED, 1);
  }
  else
  {
    digitalWrite(PIN_LED, 0);
  }

  /* Find a %d filename that is free to use */
  char file_name[16];
  int file_num = 0;
  do
  {
    snprintf(file_name, 16, "/%d", file_num);
    file_num++;
  } while (SD.exists(file_name));

  /* Open the file */
  // old esp32 code
  //auto file = SD.open(file_name, FILE_WRITE, true);

  // new arduino code
  auto file = SD.open(file_name, FILE_WRITE);


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

static void sensor_print_init_success_state(const char *name, bool was_successful)
{
  if (was_successful)
  {
    Serial.printf("%s initialization succeeded\n", name);
  }
  else
  {
    Serial.printf("%s initialization failed\n", name);
  }
}

static void sensors_setup()
{
  //old esp32 syntax
  //Wire.begin(PIN_I2C_SDA, PIN_I2C_SCL, 200000);

  //switch to arduino syntax
  Wire.begin();
  Wire.setClock(200000);

  /* Initialize sensor drivers */
  //old esp32 code
  //esp_err_t status;

  //new arduino code
  bool status;

  bool retry = false;
  int num_retries = 0;

  do
  {
    if (retry)
    {
      retry = false;
      num_retries += 1;
      Serial.printf("Retrying to initialize sensors...\n");
    }
 
    status = fc_bm1422_initialize(&bm1422);
    if (status != true)
      retry = true;
    sensor_print_init_success_state("bm1422", status);

    status = fc_adxl375_initialize(&adxl375);
    if (status != true)
      retry = true;
    sensor_print_init_success_state("adxl375", status);

    status = fc_bmi323_initialize(&bmi323);
    if (status != true)
      retry = true;
    sensor_print_init_success_state("bmi323", status);

    status = fc_ms5607_initialize(&ms5607);
    if (status != true)
      retry = true;
    sensor_print_init_success_state("ms5607", status);

  } while (retry && num_retries < 50);
}


void sd_setup()
{
  SPI.begin(PIN_SPI_CLK, PIN_SPI_MISO, PIN_SPI_MOSI);
  log_file = sdcard_and_logging_init();
}

void lora_and_sd_setup()
{
  SPI.begin(7, 6, 5);
  LoRa.setSPI(SPI);
  LoRa.setPins(4, 18);
  LoRa.setTxPower(20);
  pinMode(PIN_LED, OUTPUT);
  while (!LoRa.begin(433E6))
  {
    delay(500);
    digitalWrite(PIN_LED, 1);
    delay(500);
    digitalWrite(PIN_LED, 0);
  }

  digitalWrite(PIN_LED, 1);
  delay(250);
  digitalWrite(PIN_LED, 0);
  delay(250);
  digitalWrite(PIN_LED, 1);

  LoRa.setSignalBandwidth(125E3);
  LoRa.setSpreadingFactor(12);
  LoRa.setPreambleLength(8);

  log_file = sdcard_and_logging_init();
}

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
        digitalWrite(PIN_LED, !digitalRead(PIN_LED));
      }
      /*
      Serial.print("Lat: ");
      Serial.print(gps.location.lat(), 6);
      Serial.print(" | Lon: ");
      Serial.print(gps.location.lng(), 6);
      Serial.print(" | Sats: ");
      Serial.print(gps.satellites.value());
      Serial.print(" | Alt: ");
      Serial.print(gps.altitude.meters());
      Serial.println(" m");
      */
    }

    vTaskDelayUntil(&time, interval_ms);
  }
}

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
  Serial.begin(115200);

  GPSSerial.begin(9600, SERIAL_8N1, PIN_GPS_RX, PIN_GPS_TX);

  sd_setup();
  sensors_setup();

  data_log_loop(); 
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
