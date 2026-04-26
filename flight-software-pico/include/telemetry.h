#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#define TELEMETRY_PACKET_MAX_LEN 255
#define TELEMETRY_PACKET_MAGIC "FUCKPETER"
#define LOG_PACKET_MAGIC "COREYMAY3"

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

struct __attribute__((packed)) telemetry_packet {
    char magic[9]; // 'FUCKPETER' in ASCII with no null terminator
    uint8_t size; // Total size of struct
    uint16_t crc16;

    uint8_t status_flags; // StatusFlags bitfield
    uint8_t rocket_flags;
    uint32_t time_boot_ms; // Timestamp (ms since system boot)
    float pitch; // Fused sensor data (unit: Euler angle deg)
    float yaw;   // Fused sensor data (unit: Euler angle deg)
    float roll;  // Fused sensor data (unit: Euler angle deg)
    float accel_magnitude; // Magnitude of acceleration (unit: G)
    float ms5607_pressure_mbar; // Pressure (unit: mbar)
};

struct __attribute__((packed)) log_packet_v3 {
    char magic[9]; // 'COREYMAYS' in ASCII with no null terminator
    uint8_t size; // Total size of struct
    uint16_t crc16;

    uint8_t status_flags; // StatusFlags bitfield
    uint32_t time_boot_ms; // Timestamp (ms since system boot)
    float ms5607_pressure_mbar; // MS5607 Air Pressure (unit: mbar)
    float ms5607_temperature_c; // MS5607 Temperature (unit: degrees C)
    float bmi323_accel_x; // BMI323 Acceleration X (unit: G)
    float bmi323_accel_y; // BMI323 Acceleration Y (unit: G)
    float bmi323_accel_z; // BMI323 Acceleration Z (unit: G)
    float bmi323_gyro_x; // BMI323 Gyroscope X (unit: deg/s)
    float bmi323_gyro_y; // BMI323 Gyroscope Y (unit: deg/s)
    float bmi323_gyro_z; // BMI323 Gyroscope Z (unit: deg/s)
    float adxl375_accel_x; // ADXL375 Acceleration X (unit: G)
    float adxl375_accel_y; // ADXL375 Acceleration Y (unit: G)
    float adxl375_accel_z; // ADXL375 Acceleration Z (unit: G)
    float bm1422_magn_x; // BM1422 Magnetic Field X
    float bm1422_magn_y; // BM1422 Magnetic Field Y
    float bm1422_magn_z; // BM1422 Magnetic Field Z
    float gps_lat; // Latitude  (unit: degres)
    float gps_lng; // Longitude (unit: degrees)
    float gps_alt; // Altitude  (unit: meters)
    float gps_speed;
    float pt_volts;
    int32_t gps_course;
    uint8_t gps_num_sats;
};

void telemetry_packet_make_header(struct telemetry_packet *p);
void log_packet_make_header(struct log_packet_v3 *p);

#ifdef __cplusplus
}
#endif
