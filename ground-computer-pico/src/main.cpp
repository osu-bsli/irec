#include <cstdlib>
#include <cstring>

#include <Arduino.h>

#include <SPI.h>
#include <LoRa.h>
#include <SerialUSB.h>

#include "checksum.h"

#include "../../flight-software-pico/include/telemetry.h"
#include "../../flight-software-pico/include/pins.h"
#include "../../flight-software-pico/src/config.h"

/* IMPORTANT: whenever fields are added, removed, or reordered in telemetry_packet
   (flight-software-pico/include/telemetry.h), also update
   print_formatted_telemetry_to_serial() below — sizeof() and CRC are automatic
   but the printf format string is not. */

static void lora_receive_packet_isr_callback(int packet_size);
static void print_formatted_telemetry_to_serial(const telemetry_packet &p);
static void send_command(uint8_t command_byte, uint32_t command_arg = 0);

#define CRLF "\r\n"
#define SEP  "================================================================================" CRLF

// ---------------------------------------------------------------------------
// LoRa
// ---------------------------------------------------------------------------

static void lora_setup()
{
    Serial.println("Setting up LoRa...");
    SPI.setSCK(PIN_LORA_SCK);
    SPI.setMOSI(PIN_LORA_MOSI);
    SPI.setMISO(PIN_LORA_MISO);
    LoRa.setSPI(SPI);
    LoRa.setPins(PIN_LORA_CS, PIN_LORA_RESET, PIN_LORA_IRQ_PIN0);
    if (!LoRa.begin(CONFIG_LORA_FREQUENCY_HZ_INITIAL))
        Serial.println("LoRa initialization failed");
    LoRa.setGain(6);
    LoRa.onReceive(lora_receive_packet_isr_callback);
    LoRa.receive();
}

static volatile bool packet_recvd_isr_flag = 0;
static volatile telemetry_packet packet_recvd_isr_data;

/* DO NOT USE SerialUSB in an ISR — IT WILL BREAK */
static void lora_receive_packet_isr_callback(int packet_size)
{
    if (packet_size != sizeof(telemetry_packet))
        return;

    uint8_t buf[sizeof(telemetry_packet)];
    for (int i = 0; i < (int)sizeof(telemetry_packet); i++)
    {
        int b = LoRa.read();
        if (b == -1) return;
        buf[i] = b;
    }

    /* cannot use memcpy on volatiles */
    for (size_t i = 0; i < sizeof(telemetry_packet); i++)
        ((uint8_t *)&packet_recvd_isr_data)[i] = buf[i];

    packet_recvd_isr_flag = 1;
}

/* Copy and validate the latest ISR packet. Returns false if no packet ready
   or if magic/CRC checks fail. */
static bool try_recv_telemetry(telemetry_packet *out)
{
    if (!packet_recvd_isr_flag)
        return false;
    packet_recvd_isr_flag = 0;

    telemetry_packet p;
    for (size_t i = 0; i < sizeof(telemetry_packet); i++)
        ((uint8_t *)&p)[i] = ((uint8_t *)&packet_recvd_isr_data)[i];

    if (memcmp(p.magic, TELEMETRY_PACKET_MAGIC, sizeof(p.magic)) != 0)
        return false;

    uint16_t expected_crc = p.crc16;
    p.crc16 = 0;
    if (crc_modbus((const unsigned char *)&p, sizeof(telemetry_packet)) != expected_crc)
        return false;

    *out = p;
    return true;
}

static void print_formatted_telemetry_to_serial(const telemetry_packet &p)
{
    Serial.printf(
        "time_boot_ms:                    %lu ms" CRLF
        "ms5607_pressure_mbar:            %.2f mbar" CRLF
        "ms5607_temperature_c:            %.2f C" CRLF
        "bmi323_accel_magnitude_milliG:   %u mG  (cal: %u mG)" CRLF
        "adxl375_accel_magnitude_milliG:  %u mG  (cal: %u mG)" CRLF
        "commanded_airbrake_deploy_pct:   %u%%" CRLF
        "altitude_angle_mrad:             %u mrad" CRLF
        "airbrakes_servo_mA:              %u mA" CRLF
        "battery_mV:                      %u mV" CRLF
        "is_in_operational_mode:          %u" CRLF
        "status_flags:                    0x%02x" CRLF
        "runtime_task:         %u us  (max %u)" CRLF
        "deploy_task:          %u us  (max %u)" CRLF
        "servo_overcurrent:    %u us  (max %u)" CRLF
        "sdcard_write:         %u us  (max %u)" CRLF
        "gps_lat_deg:          %f" CRLF
        "gps_lng_deg:          %f" CRLF
        "gps_alt_m:            %f" CRLF
        "gps_num_sats:         %u" CRLF,
        (unsigned long)p.time_boot_ms,
        p.ms5607_pressure_mbar,
        p.ms5607_temperature_c,
        p.bmi323_accel_magnitude_milliG,  p.bmi323_accel_magnitude_cal_milliG,
        p.adxl375_accel_magnitude_milliG, p.adxl375_accel_magnitude_cal_milliG,
        p.commanded_airbrake_deploy_pct,
        p.altitude_angle_mrad,
        p.airbrakes_servo_mA,
        p.battery_mV,
        p.is_in_operational_mode,
        (unsigned)p.status_flags,
        p.runtime_task_iter_us,          p.runtime_task_iter_max_us,
        p.deploy_task_iter_us,           p.deploy_task_iter_max_us,
        p.servo_overcurrent_task_iter_us, p.servo_overcurrent_task_iter_max_us,
        p.sdcard_write_task_iter_us,     p.sdcard_write_task_iter_max_us,
        p.gps_lat_deg,
        p.gps_lng_deg,
        p.gps_alt_m,
        p.gps_num_sats
    );
}

static void send_command(uint8_t command_byte, uint32_t command_arg)
{
    command_packet p;
    memcpy(p.magic, COMMAND_PACKET_MAGIC, sizeof(p.magic));
    p.size         = sizeof(command_packet);
    p.crc16        = 0;
    memcpy(p.cmd, "CMD", sizeof(p.cmd));
    p.command_byte = command_byte;
    p.command_arg  = command_arg;
    p.crc16        = crc_modbus((const unsigned char *)&p, sizeof(command_packet));

    /* endPacket() is blocking — radio is done transmitting before we restore RX */
    LoRa.beginPacket();
    LoRa.write((uint8_t *)&p, sizeof(command_packet));
    LoRa.endPacket();
    LoRa.receive();
}

// ---------------------------------------------------------------------------
// Menu and prompts
// ---------------------------------------------------------------------------

static void print_main_menu()
{
    Serial.print(
        CRLF SEP
        "  BSLI GROUND COMPUTER" CRLF
        SEP
        "  [M]  Monitor telemetry" CRLF
        "  [S]  Switch to operational mode" CRLF
        "  [D]  Deploy airbrakes" CRLF
        "  [A]  Stow airbrakes" CRLF
        "  [F]  Set LoRa frequency" CRLF
        "  [B]  Set LoRa bandwidth" CRLF
        SEP
        "> "
    );
}

static void monitor_telemetry()
{
    Serial.print(
        CRLF SEP
        "  TELEMETRY MONITOR  (press any key to return to menu)" CRLF
        SEP CRLF
    );

    while (!Serial.available())
    {
        telemetry_packet p;
        if (try_recv_telemetry(&p))
        {
            Serial.print("---" CRLF);
            Serial.printf("[LoRa RSSI]: %ld dBm" CRLF, LoRa.packetRssi());
            Serial.printf("[LoRa freq]: %ld Hz" CRLF, LoRa.getFrequency());
            print_formatted_telemetry_to_serial(p);
        }
    }
    while (Serial.available()) Serial.read();
    Serial.print(CRLF "Returning to menu..." CRLF);
}

/* Read a line from Serial with echo and backspace support.
   Blocks until Enter is pressed. */
static void read_line(char *buf, int buf_size)
{
    int i = 0;
    memset(buf, 0, buf_size);
    while (true)
    {
        if (!Serial.available()) continue;
        int c = Serial.read();
        if (c == '\r' || c == '\n')
        {
            delay(5);
            while (Serial.available() && (Serial.peek() == '\r' || Serial.peek() == '\n'))
                Serial.read();
            Serial.print(CRLF);
            return;
        }
        if ((c == 127 || c == '\b') && i > 0)
        {
            i--;
            buf[i] = '\0';
            Serial.print("\b \b");
        }
        else if (c >= 32 && i < buf_size - 1)
        {
            buf[i++] = (char)c;
            buf[i]   = '\0';
            Serial.write((uint8_t)c);
        }
    }
}

/* Literal is defined separately to allow it to be used in string token concatenations. */
#define SWITCH_CONFIRMATION_LITERAL "Switch to operational mode. I understand this is irreversible without a reboot!"
static const char SWITCH_CONFIRMATION[] = SWITCH_CONFIRMATION_LITERAL;

static void prompt_switch_to_operational()
{
    Serial.print(
        CRLF SEP
        "  !!! SWITCH TO OPERATIONAL MODE !!!" CRLF
        SEP
        "  This action is IRREVERSIBLE without a physical reboot." CRLF
        "  The flight computer will arm and begin active airbrake control." CRLF
        CRLF
        "  Type the following EXACTLY then press Enter. Empty line cancels." CRLF
        CRLF
        "    \"Switch to operational mode. I understand this is irreversible without a reboot!\"" CRLF
        CRLF SEP
        "> "
    );

    char buf[128];
    read_line(buf, sizeof(buf));

    if (buf[0] == '\0')
    {
        Serial.print("Cancelled." CRLF);
    }
    else if (strcmp(buf, SWITCH_CONFIRMATION) == 0)
    {
        Serial.print("Confirmation accepted. Sending command..." CRLF);
        for (int i = 0; i < 10; i++ ) 
        {
            send_command(RADIO_COMMAND_SWITCH_TO_OPERATIONAL_MODE);
        }
        Serial.print("SWITCH_TO_OPERATIONAL_MODE sent." CRLF);
    }
    else
    {
        Serial.print("Confirmation string did not match. Command NOT sent." CRLF);
        Serial.print("Expected: \"" SWITCH_CONFIRMATION_LITERAL "\"" CRLF);
    }
}

static void prompt_airbrake_command(const char *title, uint8_t cmd)
{
    Serial.print(CRLF SEP "  ");
    Serial.print(title);
    Serial.print(CRLF SEP);
    Serial.printf("  Send the %s command to the rocket?" CRLF, title);
    Serial.print(CRLF "  Press Y to confirm, any other key to cancel." CRLF CRLF "> ");

    while (!Serial.available());
    int c = Serial.read();
    Serial.print(CRLF CRLF);

    if (c == 'y' || c == 'Y')
    {
        Serial.print("Confirmed. Sending command..." CRLF);
        send_command(cmd);
        Serial.print(title);
        Serial.print(" command sent." CRLF);
    }
    else
    {
        Serial.print("Cancelled." CRLF);
    }
}

/* Prompt for a positive integer value (in Hz) used to retune the LoRa link.
   Returns true and writes *out_value on success, false if cancelled/invalid. */
static bool prompt_lora_value(const char *title, const char *example, uint32_t *out_value)
{
    Serial.print(CRLF SEP "  ");
    Serial.print(title);
    Serial.print(CRLF SEP);
    Serial.printf("  Enter the new value in Hz (e.g. %s). Empty line cancels." CRLF, example);
    Serial.print(
        CRLF
        "  NOTE: the ground computer is also retuned to match so the link is" CRLF
        "  preserved. If the rocket misses this command the link will desync." CRLF
        CRLF SEP
        "> "
    );

    char buf[32];
    read_line(buf, sizeof(buf));

    if (buf[0] == '\0')
    {
        Serial.print("Cancelled." CRLF);
        return false;
    }

    char *end = nullptr;
    unsigned long value = strtoul(buf, &end, 10);
    if (end == buf || *end != '\0' || value == 0)
    {
        Serial.print("Invalid value. Command NOT sent." CRLF);
        return false;
    }

    *out_value = (uint32_t)value;
    return true;
}

static void prompt_set_lora_frequency()
{
    uint32_t freq_hz;
    if (!prompt_lora_value("SET LoRa FREQUENCY", "905000000 for 905 MHz", &freq_hz))
        return;

    Serial.printf("Confirmed. Sending command (%lu Hz)..." CRLF, (unsigned long)freq_hz);
    for (int i = 0; i < 10; i++)
        send_command(RADIO_COMMAND_SET_LORA_FREQUENCY, freq_hz);

    /* Retune ourselves to match the rocket so we keep receiving telemetry. */
    LoRa.setFrequency(freq_hz);
    LoRa.receive();
    Serial.printf("SET_LORA_FREQUENCY sent. Ground computer now on %d Hz." CRLF,
                  LoRa.getFrequency());
}

static void prompt_set_lora_bandwidth()
{
    uint32_t bw_hz;
    if (!prompt_lora_value("SET LoRa BANDWIDTH", "125000 for 125 kHz", &bw_hz))
        return;

    Serial.printf("Confirmed. Sending command (%lu Hz)..." CRLF, (unsigned long)bw_hz);
    for (int i = 0; i < 10; i++)
        send_command(RADIO_COMMAND_SET_LORA_BANDWIDTH, bw_hz);

    /* Retune ourselves to match the rocket so we keep receiving telemetry. */
    LoRa.setSignalBandwidth(bw_hz);
    LoRa.receive();
    Serial.printf("SET_LORA_BANDWIDTH sent. Ground computer now at %lu Hz." CRLF,
                  (unsigned long)bw_hz);
}

// ---------------------------------------------------------------------------

void setup()
{
    Serial.begin();

    tone(PIN_BUZZER, 523, 100);
    delay(3000);
    tone(PIN_BUZZER, 523, 100);

    lora_setup();
}

void loop()
{
    print_main_menu();

    while (!Serial.available());
    char c = Serial.read();

    switch (c)
    {
        case 'm': case 'M': monitor_telemetry();                                                          break;
        case 's': case 'S': prompt_switch_to_operational();                                               break;
        case 'd': case 'D': prompt_airbrake_command("DEPLOY AIRBRAKES", RADIO_COMMAND_DEPLOY_AIRBRAKES);  break;
        case 'a': case 'A': prompt_airbrake_command("STOW AIRBRAKES",   RADIO_COMMAND_STOW_AIRBRAKES);    break;
        case 'f': case 'F': prompt_set_lora_frequency();                                                  break;
        case 'b': case 'B': prompt_set_lora_bandwidth();                                                  break;
        default: break;
    }
}
