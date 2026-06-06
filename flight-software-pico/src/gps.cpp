#include "gps.h"

#include "pins.h"

#include <Arduino.h>
#include <TinyGPS++.h>

#define GPS_BAUD_RATE 115200
#define GPS_UART_FIFO_SIZE 1024

#define GPSSerial Serial1
static TinyGPSPlus gps;

void gps_setup()
{
  GPSSerial.setRX(PIN_GPS_RX);
  GPSSerial.setTX(PIN_GPS_TX);
  GPSSerial.setFIFOSize(GPS_UART_FIFO_SIZE);
  GPSSerial.begin(GPS_BAUD_RATE, SERIAL_8N1);
}

FSError acquire_gps_data(log_packet_latest *log_p)
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
    log_p->gps_speed_mps = (float)gps.speed.mps();
  }

  if (gps.course.isValid())
  {
    log_p->gps_course = (int32_t)(gps.course.deg() * 100);
  }

  if (gps.satellites.isValid())
  {
    log_p->gps_num_sats = gps.satellites.value();
  }

  return SUCCESS;
}