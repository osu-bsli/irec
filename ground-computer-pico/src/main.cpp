#include <Arduino.h>

#include <SPI.h>
#include <LoRa.h>
#include <SerialUSB.h>

#include "checksum.h"

#include "../../flight-software-pico/include/telemetry.h"
#include "../../flight-software-pico/include/pins.h"
#include "../../flight-software-pico/src/config.h"

#define TERMINAL_ESCAPE_SEQUENCE_CLEAR "\x1b[2J"

static void lora_receive_packet_isr_callback(int packet_size);
static void print_formatted_telemetry_to_serial(telemetry_packet telemetry_p);

static void lora_setup()
{
    Serial.println("Setting up LoRa...");
    SPI.setSCK(PIN_LORA_SCK);
    SPI.setMOSI(PIN_LORA_MOSI);
    SPI.setMISO(PIN_LORA_MISO);
    LoRa.setSPI(SPI);
    LoRa.setPins(PIN_LORA_CS, PIN_LORA_RESET, PIN_LORA_IRQ_PIN0);
    if (!LoRa.begin(CONFIG_LORA_FREQUENCY_HZ))
    {
        Serial.println("LoRa initialization failed");
    }
    LoRa.setGain(6);
    LoRa.onReceive(lora_receive_packet_isr_callback);
    LoRa.receive();
}

static volatile bool packet_recvd_isr_flag = 0;
static volatile telemetry_packet packet_recvd_isr_data;

/* DO NOT USE SerialUSB in an ISR, IT WILL BREAK */
static void lora_receive_packet_isr_callback(int packet_size)
{
    /* we don't need to check packet boundaries here because LoRa already has the idea of packets */

    // discard packets of the wrong size
    if (packet_size != sizeof(telemetry_packet))
        return;

    /* read the received data into buffer */
    uint8_t buf[sizeof(telemetry_packet)];
    for (int i = 0; i < sizeof(telemetry_packet); i++)
    {
        int data_or_neg1 = LoRa.read();

        // if we run out of data while reading, return
        if (data_or_neg1 == -1)
            return;

        buf[i] = data_or_neg1;
    }
    
    // copy into global variable for non-ISR code to handle
    // cannot use memcpy because of volatiles
    for (size_t i = 0; i < sizeof(telemetry_packet); i++) {
        ((uint8_t*)&packet_recvd_isr_data)[i] = buf[i];
    }

    // set ISR flag
    packet_recvd_isr_flag = 1;
}

static void print_formatted_telemetry_to_serial(telemetry_packet telemetry_p)
{
    Serial.printf(
        "uint8_t status_flags: %d\n"
        "uint32_t time_boot_ms: %d\n"
        "uint16_t runtime_task_iter_us: %d\n"
        "uint16_t runtime_task_iter_max_us: %d\n"
        "uint16_t deploy_task_iter_us: %d\n"
        "uint16_t deploy_task_iter_max_us: %d\n"
        "uint16_t servo_overcurrent_task_iter_us: %d\n"
        "uint16_t servo_overcurrent_task_iter_max_us: %d\n"
        "uint16_t sdcard_write_task_iter_us: %d\n"
        "uint16_t sdcard_write_task_iter_max_us: %d\n"
        "uint16_t battery_mV: %d\n"
        "uint16_t airbrakes_servo_mA: %d\n"
        "bool is_in_operational_mode: %d\n"
        "uint16_t altitude_angle_mrad: %d\n"
        "float ms5607_pressure_mbar: %f\n"
        "float ms5607_temperature_c: %f\n"
        "uint16_t bmi323_accel_magnitude_milliG: %d\n"
        "uint16_t adxl375_accel_magnitude_milliG: %d\n"
        "uint16_t bmi323_accel_magnitude_cal_milliG: %d\n"
        "uint16_t adxl375_accel_magnitude_cal_milliG: %d\n"
        "uint8_t commanded_airbrake_deploy_pct: %d\n",

        telemetry_p.status_flags,
        telemetry_p.time_boot_ms,
        telemetry_p.runtime_task_iter_us,
        telemetry_p.runtime_task_iter_max_us,
        telemetry_p.deploy_task_iter_us,
        telemetry_p.deploy_task_iter_max_us,
        telemetry_p.servo_overcurrent_task_iter_us,
        telemetry_p.servo_overcurrent_task_iter_max_us,
        telemetry_p.sdcard_write_task_iter_us,
        telemetry_p.sdcard_write_task_iter_max_us,
        telemetry_p.battery_mV,
        telemetry_p.airbrakes_servo_mA,
        telemetry_p.is_in_operational_mode,
        telemetry_p.altitude_angle_mrad,
        telemetry_p.ms5607_pressure_mbar,
        telemetry_p.ms5607_temperature_c,
        telemetry_p.bmi323_accel_magnitude_milliG,
        telemetry_p.adxl375_accel_magnitude_milliG,
        telemetry_p.bmi323_accel_magnitude_cal_milliG,
        telemetry_p.adxl375_accel_magnitude_cal_milliG,
        telemetry_p.commanded_airbrake_deploy_pct);
}

void setup()
{
    // SerialUSB on arduino-pico ignores baud rate argument
    Serial.begin();

    tone(PIN_BUZZER, 523, 100);
    delay(3000);
    tone(PIN_BUZZER, 523, 100);

    lora_setup();
}

void loop()
{
    if (packet_recvd_isr_flag)
    {
        packet_recvd_isr_flag = 0;

        // take local copy of packet
        // must do byte-by-byte copy because of volatiles
        telemetry_packet p;
        for (size_t i = 0; i < sizeof(telemetry_packet); i++) {
            ((uint8_t*)&p)[i] = ((uint8_t*)&packet_recvd_isr_data)[i];
        }

        // if magic doesn't match, return
        if (memcmp(p.magic, TELEMETRY_PACKET_MAGIC, sizeof(p.magic)) != 0)
        {
            Serial.println("magic mismatch");
            return;
        }

        /* verify CRC16 match */
        uint16_t p_crc16 = p.crc16;
        p.crc16 = 0;

        uint16_t computed_crc16 = crc_modbus((const unsigned char *)&p, sizeof(struct telemetry_packet));
        // if CRC16 mismatch, return
        if (computed_crc16 != p_crc16)
        {
            Serial.println("bad crc16");
            return;
        }

        Serial.println("all checks passed");

        // if all checks pass, print data to serial
        print_formatted_telemetry_to_serial(p);
    }
}