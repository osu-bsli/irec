#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "utility.h"
#include <stdint.h>

#define TELEMETRY_PACKET_MAX_LEN 255
// Brian's callsign
#define TELEMETRY_PACKET_MAGIC "KF8EBM"
constexpr size_t TELEMETRY_PACKET_MAGIC_LEN = sizeof(TELEMETRY_PACKET_MAGIC) - 1; // minus 1 to subtract null terminator
#define LOG_PACKET_MAGIC "COREYMAY3"
constexpr size_t LOG_PACKET_MAGIC_LEN = sizeof(LOG_PACKET_MAGIC) - 1; // minus 1 to subtract null terminator

enum StatusFlags {
    STATUS_FLAGS_RECOVERY_ARMED = 1 << 0,
    STATUS_FLAGS_EMATCH_DROGUE_DEPLOYED = 1 << 1,
    STATUS_FLAGS_EMATCH_MAIN_DEPLOYED = 1 << 2,
    STATUS_FLAGS_SD_CARD_DEGRADED = 1 << 3,
    STATUS_FLAGS_ADXL375_DEGRADED = 1 << 4,
    STATUS_FLAGS_BM1422_DEGRADED = 1 << 5,
    STATUS_FLAGS_BMI323_DEGRADED = 1 << 6,
    STATUS_FLAGS_MS5607_DEGRADED = 1 << 7,
};

// TODO make this an actual thing
// enum RocketState {
//     ROCKET_PREFLIGHT,
//     ROCKET_TAKEOFF,
//     ROCKET_CRUISE,
//     ROCKET_APOGEE,
//     ROCKET_FREEFALL,
//     ROCKET_DROGUE,
//     ROCKET_LAND,
//     ROCKET_ERROR,
// };

#define RADIO_COMMAND_DEPLOY_AIRBRAKES 0x01 
#define RADIO_COMMAND_STOW_AIRBRAKES 0x02
#define RADIO_COMMAND_SET_LORA_FREQUENCY 0x03
#define RADIO_COMMAND_SET_LORA_BANDWIDTH 0x04
#define RADIO_COMMAND_SWITCH_TO_OPERATIONAL_MODE 0x67

#define COMMAND_PACKET_MAGIC TELEMETRY_PACKET_MAGIC
#define COMMAND_PACKET_MAGIC_LEN TELEMETRY_PACKET_MAGIC_LEN

PACKED_STRUCT command_packet {
    char magic[COMMAND_PACKET_MAGIC_LEN]; // Brian's callsign in ASCII with no null terminator
    uint8_t size; // Total size of struct
    uint16_t crc16;

    char cmd[3]; // "CMD"
    uint8_t command_byte;
    uint32_t command_arg;
};
END_PACKED_STRUCT;

/* IMPORTANT: whenever fields are added, removed, or reordered here, also update
   print_formatted_telemetry_to_serial() in ../ground-computer-pico/src/main.cpp.
   The ground computer includes this header directly so sizeof() and CRC are
   automatically correct, but the hardcoded printf format string is not. */
PACKED_STRUCT telemetry_packet {
    char magic[TELEMETRY_PACKET_MAGIC_LEN]; // Brian's callsign in ASCII with no null terminator
    uint8_t size; // Total size of struct
    uint16_t crc16;

    uint8_t status_flags; // StatusFlags bitfield
    uint32_t time_boot_ms; // Timestamp (ms since system boot)
    uint16_t runtime_task_iter_us;
    uint16_t runtime_task_iter_max_us;
    uint16_t deploy_task_iter_us;
    uint16_t deploy_task_iter_max_us;
    uint16_t servo_overcurrent_task_iter_us;
    uint16_t servo_overcurrent_task_iter_max_us;
    uint16_t sdcard_write_task_iter_us;
    uint16_t sdcard_write_task_iter_max_us;
    uint16_t battery_mV;
    uint16_t airbrakes_servo_mA; 
    bool is_in_operational_mode;
    uint16_t altitude_angle_mrad; // Altitude angle; angle from horizon (unit: mrad) 
    float ms5607_pressure_mbar; 
    float ms5607_temperature_c; 
    uint16_t bmi323_accel_magnitude_milliG;
    uint16_t adxl375_accel_magnitude_milliG;
    uint16_t bmi323_accel_magnitude_cal_milliG;
    uint16_t adxl375_accel_magnitude_cal_milliG;
    uint8_t commanded_airbrake_deploy_pct;
    float gps_lat_deg; 
    float gps_lng_deg;
    float gps_alt_m;
    uint8_t gps_num_sats;
};
END_PACKED_STRUCT;

PACKED_STRUCT log_packet_v3 {
    char magic[LOG_PACKET_MAGIC_LEN]; // 'COREYMAY3' in ASCII with no null terminator
    uint8_t size; // Total size of struct
    uint16_t crc16;

    uint8_t status_flags; // StatusFlags bitfield
    uint32_t time_boot_ms; // Timestamp (ms since system boot)
    float ms5607_pressure_mbar; // MS5607 Air Pressure (unit: mbar)
    float ms5607_temperature_c; // MS5607 Temperature (unit: degrees C)
    float bmi323_accel_x_G; // BMI323 Acceleration X (unit: G)
    float bmi323_accel_y_G; // BMI323 Acceleration Y (unit: G)
    float bmi323_accel_z_G; // BMI323 Acceleration Z (unit: G)
    float bmi323_gyro_x_degps; // BMI323 Gyroscope X (unit: deg/s)
    float bmi323_gyro_y_degps; // BMI323 Gyroscope Y (unit: deg/s)
    float bmi323_gyro_z_degps; // BMI323 Gyroscope Z (unit: deg/s)
    float adxl375_accel_x_G; // ADXL375 Acceleration X (unit: G)
    float adxl375_accel_y_G; // ADXL375 Acceleration Y (unit: G)
    float adxl375_accel_z_G; // ADXL375 Acceleration Z (unit: G)
    float bm1422_magn_x; // BM1422 Magnetic Field X
    float bm1422_magn_y; // BM1422 Magnetic Field Y
    float bm1422_magn_z; // BM1422 Magnetic Field Z
    float gps_lat_deg; // Latitude  (unit: degres)
    float gps_lng_deg; // Longitude (unit: degrees)
    float gps_alt_m; // Altitude  (unit: meters)
    float gps_speed_mps;
    float pt_volts;
    int32_t gps_course;
    uint8_t gps_num_sats;
};
END_PACKED_STRUCT;

typedef struct log_packet_v3 log_packet_latest;

void telemetry_packet_make_header(struct telemetry_packet *p);
void log_packet_make_header(log_packet_latest *p);

#ifdef __cplusplus
}
#endif
