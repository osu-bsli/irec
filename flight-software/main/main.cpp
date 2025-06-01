#include <SPI.h>
#include <LoRa.h>
#include <SD.h>
#include <Wire.h>

#include "AltimeterFilter.h"
#include "sensors/adxl375.h"
#include "sensors/bm1422.h"
#include "sensors/bmi323.h"
#include "sensors/ms5607.h"

#include "test_data.h"

const char *text_err_lora = "ERR LORA";
const char *text_err_sd = "ERR SD";

#define PIN_LED 3

static fs::File sdcard_and_logging_init()
{

  /* Set up SD card */

  // TODO: Maybe try re-opening the SD card if it disconnects mid-flight

  if (SD.begin(19))
  {
    Serial.println("SD card initialized!");
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

static fs::File log_file;

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

static struct fc_adxl375 adxl375;
static struct fc_bmi323 bmi323;
static struct fc_ms5607 ms5607;
static struct fc_bm1422 bm1422;

static void sensors_init()
{
  Wire.begin(13, 12, 200000);

  /* Initialize sensor drivers */
  esp_err_t status;

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
    if (status != ESP_OK)
      retry = true;
    sensor_print_init_success_state("bm1422", status == ESP_OK);

    status = fc_adxl375_initialize(&adxl375);
    if (status != ESP_OK)
      retry = true;
    sensor_print_init_success_state("adxl375", status == ESP_OK);

    status = fc_bmi323_initialize(&bmi323);
    if (status != ESP_OK)
      retry = true;
    sensor_print_init_success_state("bmi323", status == ESP_OK);

    status = fc_ms5607_initialize(&ms5607);
    if (status != ESP_OK)
      retry = true;
    sensor_print_init_success_state("ms5607", status == ESP_OK);

  } while (retry && num_retries < 50);
}

/*
Ping the servo to check if it is ready.
*/

#include <SCServo.h>
#include "airbrakes.h"

SMS_STS sms_sts;
// the uart used to control servos.
// GPIO 18 - S_RXD, GPIO 19 - S_TXD, as default.
#define S_RXD 12
#define S_TXD 12

int TEST_ID = 3;

void setup_servo()
{
  Serial1.begin(1000000, SERIAL_8N1, S_RXD, S_TXD);
  sms_sts.pSerial = &Serial1;
  delay(1000);
}

void ping_servo()
{
  int ID = sms_sts.Ping(TEST_ID);
  if (ID != -1)
  {
    Serial.print("Servo ID:");
    Serial.println(ID, DEC);
    delay(100);
  }
  else
  {
    Serial.println("Ping servo ID error!");
    delay(2000);
  }
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

void setup()
{
  Serial.begin(115200);

  // lora_and_sd_setup();
  // sensors_init();
  // setup_servo();

  TickType_t t = 0;

  airbrakes_init();

  int i = 0;
  while (i < DATA_LEN)
  {
    auto pressure_mbar = ms5607_pressure_mbar[i];
    auto accel_z_mps2 = adxl375_accel_z_mps2_fc_frame[i];
    airbrakes_process(pressure_mbar, accel_z_mps2);
    xTaskDelayUntil(&t, 10);
    if (i % 100 == 0) {
      Serial.println(i);
    }
    i++;
  }
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
