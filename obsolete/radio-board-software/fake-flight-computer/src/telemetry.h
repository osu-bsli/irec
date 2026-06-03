#pragma once

#include <stdint.h>

#define TELEMETRY_PACKET_MAX_LEN 255
#define TELEMETRY_PACKET_MAGIC "KF8EBM"

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

/*
 * UNALIGNED ACCESSES ARE OK ON CORTEX-M7 BUT NOT CORTEX-M0. BE AWARE!!
 */

struct __attribute__((packed)) telemetry_packet {
    char magic[6]; // 'KF8EBM' in ASCII with no null terminator - Brian Jia's callsign

    uint8_t status_flags; // StatusFlags bitfield
    uint32_t time_boot_ms; // Timestamp (ms since system boot)
    float ms5607_pressure_mbar; // Pressure (unit: mbar)
    float ms5607_pressure_mbar_min; // Pressure minimum recorded (unit: mbar)
};

void telemetry_packet_make_header(struct telemetry_packet *p);
