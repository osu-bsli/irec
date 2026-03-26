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

// C
#include <stdio.h>
#include <string>

// Flight Computer
#include <error.h>
#include "AltimeterFilter.h"
#include "sensors/adxl375.h"
#include "sensors/bm1422.h"
#include "sensors/bmi323.h"
#include "sensors/ms5607.h"
#include "pins.h"
#include "test_data.h"
#include "telemetry.h"
#include <error.h>

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

#define I2C_SENSOR_FREQUENCY 200000
#define I2C_PRESSURE_TRANSDUCER_FREQUENCY 400000
#define LOG_INTERVAL_MS 10
#define MAX_SERVO_CURRENT_AMPS 1.8

#define ADC_RESOLUTION_BITS 12

const static TickType_t interval_ms = LOG_INTERVAL_MS; // 100 Hz

static fs::File log_file;

static struct fc_adxl375 adxl375;
static struct fc_bmi323 bmi323;
static struct fc_ms5607 ms5607;
static struct fc_bm1422 bm1422;

#define GPSSerial Serial2
static TinyGPSPlus gps;


//static bool sd_card_initialized_success = false;

// TODO explicitly pass in the SPI bus
/// Initialize state for writing to the SD card
static FSError sdcard_and_logging_init(fs::File *fileOut)
{

  // Set up SD card

  // TODO: Maybe try re-opening the SD card if it disconnects mid-flight

  SPI1.setMISO(PIN_FS_SPI_MISO);
  SPI1.setMOSI(PIN_FS_SPI_MOSI);
  ////SPI.setCS(PIN_SD_CS);
  SPI1.setSCK(PIN_FS_SPI_SCK);

  if (!SD.begin(PIN_SD_CS))
  {
    Serial.printf("SD card initialized\n\r");
  }
  else
  {
    return SD_CARD_INIT_FAILURE;
  }

  //Open root

  auto root_file = SD.open("/");
  if (!root_file) {
    return FS_NOT_FOUND;
  }
  
  bool finished_directory = false;
  while (!finished_directory) {
    File entry = root_file.openNextFile();
    if (!entry) {
      finished_directory = true;
    } else {
      Serial.printf("\t%s\n\r", entry.name());
    }
  }

  return SUCCESS;

  // Find a %d filename that is free to use
  char file_name[16];
  int file_num = 0;
  do
  {
    snprintf(file_name, 16, "/%d", file_num);
    file_num++;
  } while (SD.exists(file_name));

  // Open the file
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
    return SD_CARD_FILE_OPEN_FAILURE;
  }

  *fileOut = file;
  return SUCCESS;
}



/// Due to the nature of the PICO we can configure
/// nearly every pin to do multiple functions.
/// As such all the pin configuration should
/// logically all be in one function.
static void gpio_config() {

  // sensor i2c configuration

  i2c_init(i2c0, I2C_SENSOR_FREQUENCY);
  gpio_set_function(PIN_I2C0_SDA, GPIO_FUNC_I2C);
  gpio_set_function(PIN_I2C0_SCL, GPIO_FUNC_I2C);
  gpio_pull_up(PIN_I2C0_SDA);
  gpio_pull_up(PIN_I2C0_SCL);

  bi_decl(bi_2pins_with_func(PIN_I2C0_SDA, PIN_I2C0_SCL, GPIO_FUNC_I2C));
}

static FSError sensors_setup()
{
  // Initialize sensor drivers
  FSError result = SUCCESS;

  bool retry = false;
  int num_retries = 0;
  const int MAX_RETRIES = 0;

  do
  {
    if (result != SUCCESS) {
      Serial.printf("[Error] %i/%d Retrying to initialize sensors...\n\r", MAX_RETRIES, num_retries + 1);
      num_retries += 1;
    }

    result = SUCCESS;

    // const FSError bm1422_status = fc_bm1422_initialize(&bm1422);
    const FSError adxl375_status = fc_adxl375_initialize(&adxl375);
    const FSError bmi323_status = fc_bmi323_initialize(&bmi323);
    const FSError ms5607_status = fc_ms5607_initialize(&ms5607);

    // Serial.printf("[Info] bm1422 status: %s\n\r", FCError__strings[bm1422_status]);
    Serial.printf("[Info] adxl375 status: %s\n\r", FCError__strings[adxl375_status]);
    Serial.printf("[Info] bmi323 status: %s\n\r", FCError__strings[bmi323_status]);
    Serial.printf("[Info] ms5607 status: %s\n\r", FCError__strings[ms5607_status]);

    // if (bm1422_status != SUCCESS) {
     // result = bm1422_status;
    // }

    if (adxl375_status != SUCCESS) {
      result = adxl375_status;
    }

    if (bmi323_status != SUCCESS) {
     result = bmi323_status;
    }

    if (ms5607_status != SUCCESS) {
      result = ms5607_status;
    }

  } while (result != SUCCESS && num_retries < MAX_RETRIES);

  return result;
}


void sd_setup()
{
  // PIN_SPI_CLK, PIN_SPI_MISO, PIN_SPI_MOSI
  //SPI.beginTransaction(SPISettings(8000000, MSBFIRST, SPI_MODE0));
  //log_file = sdcard_and_logging_init();
}

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

void print_log_packet(struct log_packet_v3 *p) {
  const uint8_t status_flags = *(&(p->status_flags)+1);
  Serial.printf(
    "[Packet Print]\n\rmagic: %c%c%c%c%c%c%c%c%c\n\rsize: %u\n\rcrc: %02x\n\rstatus flags: %u\n\rtime_boot_ms: %lu\n\rms5607_pressure_mbar: %f\n\rms5607_temperature_c: %f\n\rbmi323_accel_z: %f\n\rbmi323_accel_y: %f\n\rbmi323_accel_z: %f\n\rbmi323_gyro_x: %f\n\rbmi323_gyro_y: %f\n\rbmi323_gyro_z: %f\n\radxl375_accel_x: %f\n\radxl375_accel_y: %f\n\radxl375_accel_z: %f\n\rbm1422_magn_x: %f\n\rbm1422_magn_y: %f\n\rbm1422_magn_z: %f\n\rgps_lat: %f\n\rgps_lng: %f\n\rgps_alt: %f\n\rgps_speed: %f\n\rgps_course: %lu\n\rgps_num_sats: %u\n\rpt_volts: %f\n\r",
    p->magic[0],
    p->magic[1],
    p->magic[2],
    p->magic[3],
    p->magic[4],
    p->magic[5],
    p->magic[6],
    p->magic[7],
    p->magic[8],
    p->magic[9],
    p->size,
    p->crc16,
    p->status_flags,
    p->time_boot_ms,
    p->ms5607_pressure_mbar,
    p->ms5607_temperature_c,
    p->bmi323_accel_x,
    p->bmi323_accel_y,
    p->bmi323_accel_z,
    p->bmi323_gyro_x,
    p->bmi323_gyro_y,
    p->bmi323_gyro_z,
    p->adxl375_accel_x,
    p->adxl375_accel_y,
    p->adxl375_accel_z,
    p->bm1422_magn_x,
    p->bm1422_magn_y,
    p->bm1422_magn_z,
    p->gps_lat,
    p->gps_lng,
    p->gps_alt,
    p->gps_speed,
    p->gps_course,
    p->gps_num_sats,
    p->pt_volts
  );
}

/// Write log packet to SD Card
void log_data(
  struct log_packet_v3 *log_p
)
{
    // struct fc_bm1422_data bm1422_data;
    // fc_bm1422_process(&bm1422, &bm1422_data);

//  Serial.printf(
//                "[log packet]\n\rpressure: %f \n\rtemperature: %f\n\r",
//                log_p.ms5607_pressure_mbar,
//                log_p.ms5607_temperature_c
//              );

    // while (GPSSerial.available())
    // {
    //   gps.encode(GPSSerial.read());
    // }

    // if (gps.location.isValid())
    // {
    //   log_p.gps_lat = gps.location.lat();
    //   log_p.gps_lng = gps.location.lng();
    // }
    
    // if (gps.altitude.isValid())
    // {
    //   log_p.gps_alt = gps.altitude.meters();
    // }
    
    // if (gps.speed.isValid())
    // {
    //   log_p.gps_speed = gps.speed.value();
    // }
    
    // if (gps.course.isValid())
    // {
    //   log_p.gps_course = gps.course.value();
    // }

    // if (gps.satellites.isValid())
    // {
    //   log_p.gps_num_sats = gps.satellites.value();
    // }

    // log_packet_make_header(&log_p);
    // log_file.write((uint8_t *)&log_p, sizeof(log_p));
    // log_file.flush();

    // if (time % 1000 == 0)
    // {
      // if (sd_card_initialized_success)
      // {
        // digitalWrite(ACTIVITY_PIN_LED, !digitalRead(ACTIVITY_PIN_LED));
      // }
      
      //Serial.print("Lat: ");
      //Serial.print(gps.location.lat(), 6);
      //Serial.print(" | Lon: ");
      //Serial.print(gps.location.lng(), 6);
      //Serial.print(" | Sats: ");
      //Serial.print(gps.satellites.value());
      //Serial.print(" | Alt: ");
      //Serial.print(gps.altitude.meters());
      //Serial.println(" m");
      
    // }
}

/// TODO probably add more sensor state for PT and GPS or something
/// Produces a bitfield corresponding to which sensors are properly reading data
uint8_t get_sensor_state() {
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
FSError acquire_sensor_data(
  struct log_packet_v3 *log_p
) {
  struct fc_adxl375_data adxl375_data;
  const FSError adxl_status = fc_adxl375_process(&adxl375, &adxl375_data);

  if (adxl_status != SUCCESS) {
    // TODO maybe an error somewhere in the log
    return adxl_status;
    // Serial.printf("adxl read error\n\r");
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

  if (bmi323_status != SUCCESS) {
    // TODO maybe an error somewhere in the log
    // Serial.printf("bmi323 read error\n\r");
    return bmi323_status;
  }

  struct fc_ms5607_data ms5607_data;
  const FSError ms5607_status = fc_ms5607_process(&ms5607, &ms5607_data);

  if (ms5607_status != SUCCESS) {
    // TODO maybe an error somewhere in the log
    // Serial.printf("ms5607 read error\n\r");
    return ms5607_status;
  }

  return SUCCESS;
}

void init_airbrakes(Servo *servo) {
  // Allow current to the air brakes
  pinMode(PIN_ENABLE_AIRBRAKES, OUTPUT);
  digitalWrite(PIN_ENABLE_AIRBRAKES, HIGH);

  (*servo).attach(PIN_AIRBRAKES_TX, 900, 2100);

  // Current sense setup
  analogReadResolution(ADC_RESOLUTION_BITS);
}

FSError servo_overcurrent() {
  const int ADC_STEPS = (1 << int(ADC_RESOLUTION_BITS)) - 1;
  const float MAX_EXPECTED_VOLTAGE = 3.3;
  const int GAIN = 50;
  const float CSENSE_RESISTANCE = 0.01;

  const int csense_raw = analogRead(PIN_CSENSE);
  const float csense_voltage = ((float) csense_raw) / ADC_STEPS * MAX_EXPECTED_VOLTAGE;
  const float servo_current = csense_voltage / CSENSE_RESISTANCE / GAIN;
  //Serial.printf("%d %fV %fA\n\r", csense_raw, csense_voltage, servo_current);
  if (servo_current > MAX_SERVO_CURRENT_AMPS) {
    digitalWrite(PIN_ENABLE_AIRBRAKES, LOW);
    return SERVO_OVER_CURRENT;
  }
  
  return SUCCESS;
}

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
  gpio_config();

  Serial.begin(115200);

  // const uint8_t flash_message[] = "I LOVE YURI!!!";
  // uint8_t flash_buffer[512];

  // // Zero the flash writing buffer
  // memset(flash_buffer, 0, 512);

  // SPI1.setSCK(PIN_FS_SPI_SCK);
  // SPI1.setMOSI(PIN_FS_SPI_MOSI);
  // SPI1.setMISO(PIN_FS_SPI_MISO);
  // W25N flash;
  // flash.begin(PIN_FLASH_CS);

  // //flash.
  // //SPIFlash flash(PIN_FC_CS, &SPI1);

  // fs::File file;
  // FSError sd_card_status = sdcard_and_logging_init(&file);
  // if (sd_card_status != SUCCESS) {
  //   while (true) {
  //     Serial.printf("%s\n\r", FCError__strings[sd_card_status]);
  //   }
  //   // TODO handle sd card failure
  // }

  // FLIGHT COMPUTER INITIALIZATION  

  // Sensor board
  FSError sensor_status = sensors_setup();
  if (sensor_status != SUCCESS) {
    // TODO handle sensor init failure
    while (true) {
      Serial.printf("sensor failure: %s\n\r", FCError__strings[sensor_status]);
    }
  }

  // Pressure Transducer
  Adafruit_ADS1115 pt_ads;
  pt_ads.begin(0x48, &Wire1, PIN_I2C1_SDA, PIN_I2C1_SCL);

  // FLIGHT COMPUTER RUNTIME

  TickType_t time = 0;

  while (true) {
    int start_ms = xTaskGetTickCount();

    // Acquire

    struct log_packet_v3 log_p = {
        .status_flags = get_sensor_state(),
        .time_boot_ms = xTaskGetTickCount(),
        .ms5607_pressure_mbar = NAN,
        .ms5607_temperature_c = NAN,
        .bmi323_accel_x = NAN,
        .bmi323_accel_y = NAN,
        .bmi323_accel_z = NAN,
        .bmi323_gyro_x = NAN,
        .bmi323_gyro_y = NAN,
        .bmi323_gyro_z = NAN,
        .adxl375_accel_x = NAN,
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

    FSError sensor_acquire_status = acquire_sensor_data(&log_p);

    const uint16_t adc0 = pt_ads.readADC_SingleEnded(0);
    log_p.pt_volts = pt_ads.computeVolts(adc0);

    // Produces the CRC make sure this is done last
    log_packet_make_header(&log_p);

    // TODO CRC 16 crc_modbus overflows into status flag field
    // TODO something is going on with this struct and it isn't good...

    int elapsed_ms = xTaskGetTickCount() - start_ms;

    // Validate packet

    // Process

    print_log_packet(&log_p);
    //Serial.printf("%u,%f\n\r", log_p.time_boot_ms, log_p.pt_volts);

    // TODO add air brake deployment etc.

    // Log

    log_data(&log_p);

    vTaskDelayUntil(&time, interval_ms); // TODO make this compensate for the length of the acquire, process, and log sections

    // pdMS_TO_TICKS(xTaskGetTickCount())

    //GPSSerial.begin(9600, SERIAL_8N1, PIN_GPS_RX, PIN_GPS_TX);

    // vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}

void loop()
{
  delay(100);
}
