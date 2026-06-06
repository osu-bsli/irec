/*
 * Stage 2 verification harness.
 *
 * Loads the firmware SITL library into a fresh dlmopen namespace (the same way
 * the OpenRocket JNI bridge will) and drives it with a synthetic ascent: one
 * LogPacketV3 sensor frame per 10 ms step, printing the firmware's commanded
 * airbrake deployment percentage for each. Running this twice and diffing the
 * "deploy" lines confirms the full firmware path (sensor acquire -> filter ->
 * deploy task -> servo) runs deterministically.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <unistd.h>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>

#include "telemetry.h" /* log_packet_v3, LOG_PACKET_MAGIC[_LEN] */

typedef void (*fw_create_t)(int);
typedef uint8_t (*fw_feed_t)(const uint8_t *, size_t);
typedef void (*fw_destroy_t)(void);

/* Standard barometric formula: pressure (mbar) for a given altitude (m). */
static float altitude_to_pressure_mbar(float h_m)
{
    return 1013.25f * powf(1.0f - 2.25577e-5f * h_m, 5.25588f);
}

int main(int argc, char **argv)
{
    const char *path = (argc > 1) ? argv[1] : "./libflight-firmware-sitl.so";

    void *h = dlmopen(LM_ID_NEWLM, path, RTLD_NOW | RTLD_LOCAL);
    if (!h)
    {
        fprintf(stderr, "dlmopen(%s): %s\n", path, dlerror());
        return 1;
    }

    auto fw_create = (fw_create_t) dlsym(h, "fw_create");
    auto fw_feed = (fw_feed_t) dlsym(h, "fw_feed_packet");
    auto fw_destroy = (fw_destroy_t) dlsym(h, "fw_destroy");
    if (!fw_create || !fw_feed || !fw_destroy)
    {
        fprintf(stderr, "dlsym: %s\n", dlerror());
        return 1;
    }

    fw_create(0);

    const int N = 200;
    uint8_t max_deploy = 0;
    printf("=== SITL deployment trace ===\n");
    for (int i = 0; i < N; i++)
    {
        float t = i * 0.01f; /* seconds */

        /* Simple synthetic coast. NOTE: the commanded deployment will read 0%
         * here because a constant-1G accelerometer gives the GNC filter a
         * near-zero velocity estimate (no launch transient to converge on), so
         * the apogee predictor sees nothing to correct. That is correct firmware
         * behaviour. This harness exists to prove the full firmware path runs
         * over dlmopen *deterministically*; realistic, filter-consistent sensor
         * frames (and hence non-zero deployment) come from OpenRocket in the
         * FULL_SITL JNI path (Stage 3). */
        float alt_m = 1000.0f + 250.0f * t - 60.0f * t * t;
        float vz = 250.0f - 120.0f * t; /* informational */

        log_packet_v3 p;
        memset(&p, 0, sizeof(p));
        memcpy(p.magic, LOG_PACKET_MAGIC, LOG_PACKET_MAGIC_LEN);
        p.time_boot_ms = (uint32_t) (i * 10); /* 100 Hz */
        p.ms5607_pressure_mbar = altitude_to_pressure_mbar(alt_m);
        p.ms5607_temperature_c = 15.0f;
        /* Specific force in sensor frame, G. Mostly gravity during coast. */
        p.bmi323_accel_x_G = 0.0f;
        p.bmi323_accel_y_G = 0.0f;
        p.bmi323_accel_z_G = 1.0f;
        p.adxl375_accel_z_G = 1.0f;
        p.bmi323_gyro_x_degps = 0.0f;
        p.bmi323_gyro_y_degps = 0.0f;
        p.bmi323_gyro_z_degps = 0.0f;
        p.gps_num_sats = 0;

        uint8_t deploy = fw_feed((const uint8_t *) &p, sizeof(p));
        if (deploy > max_deploy) max_deploy = deploy;
        if (i % 10 == 0 || deploy != 0)
            printf("deploy frame=%3d t=%ums alt=%.0fm vz=%.0f -> %u%%\n",
                   i, p.time_boot_ms, alt_m, vz, deploy);
    }
    printf("=== max commanded deployment over run: %u%% ===\n", max_deploy);

    fw_destroy();

    /* The firmware's FreeRTOS threads are still running (vTaskStartScheduler
     * never returns), so dlclose()-ing the namespace here would block. Flush our
     * output and exit hard; the OS reclaims the threads. Clean per-run teardown
     * (needed to reuse a process across many dlmopen'd runs) is Stage 4 work. */
    fflush(stdout);
    _exit(0);
}
