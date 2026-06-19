#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "../include/telemetry.h"

static const char EXPECTED_MAGIC[9] = { 'C','O','R','E','Y','M','A','Y','3' };

static const int crop_start_ms = 9496605 - 10000;
// static const int crop_end_ms = 9512905;

int main(int argc, char **argv)
{
    FILE *fp = NULL;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input.bin>\n", argv[0]);
        return 1;
    }

    if (argc == 2) {
        fp = fopen(argv[1], "rb");
        if (!fp) {
            perror("fopen");
            return 1;
        }
    } else {
        fp = stdin;
    }

    // CSV header: you can adjust / reorder columns as you like.
    printf("magic,size,crc16,status_flags,"
           "time_boot_ms,"
           "ms5607_pressure_mbar,ms5607_temperature_c,"
           "bmi323_accel_x,bmi323_accel_y,bmi323_accel_z,"
           "bmi323_gyro_x,bmi323_gyro_y,bmi323_gyro_z,"
           "adxl375_accel_x,adxl375_accel_y,adxl375_accel_z,"
           "bm1422_magn_x,bm1422_magn_y,bm1422_magn_z,"
           "gps_lat,gps_lng,gps_alt,gps_speed,gps_course,gps_num_sats\n");

    struct log_packet_v3 pkt;
    size_t nread;
    size_t packet_index = 0;
    
    FILE* fp_log_cropped = fopen("log_cropped.logv3", "w");

    while ((nread = fread(&pkt, 1, sizeof(pkt), fp)) == sizeof(pkt)) {
        packet_index++;

        // Optional sanity checks
        if (memcmp(pkt.magic, EXPECTED_MAGIC, sizeof(pkt.magic)) != 0) {
            fprintf(stderr, "Warning: packet %zu has bad magic, skipping\n",
                    packet_index);
            continue;
        }

        if (pkt.size != sizeof(struct log_packet_v3)) {
            fprintf(stderr,
                    "Warning: packet %zu has unexpected size field %u (expected %zu), skipping\n",
                    packet_index, pkt.size, sizeof(struct log_packet_v3));
            continue;
        }

        if (pkt.adxl375_accel_z_G > 10)
        {
            printf("takeoff time: %d\n", pkt.time_boot_ms);
        }

        // Print CSV row
        // Note: printing 'magic' as a 9-character field, not null-terminated.
        printf("\"%.*s\",", (int)sizeof(pkt.magic), pkt.magic);
        printf("%u,", (unsigned)pkt.size);
        printf("%u,", (unsigned)pkt.crc16);
        printf("%u,", (unsigned)pkt.status_flags);

        printf("%u,", (unsigned)pkt.time_boot_ms);

        printf("%.6f,", pkt.ms5607_pressure_mbar);
        printf("%.6f,", pkt.ms5607_temperature_c);

        printf("%.6f,", pkt.bmi323_accel_x_G);
        printf("%.6f,", pkt.bmi323_accel_y_G);
        printf("%.6f,", pkt.bmi323_accel_z_G);

        printf("%.6f,", pkt.bmi323_gyro_x_degps);
        printf("%.6f,", pkt.bmi323_gyro_y_degps);
        printf("%.6f,", pkt.bmi323_gyro_z_degps);

        printf("%.6f,", pkt.adxl375_accel_x_G);
        printf("%.6f,", pkt.adxl375_accel_y_G);
        printf("%.6f,", pkt.adxl375_accel_z_G);

        printf("%.6f,", pkt.bm1422_magn_x);
        printf("%.6f,", pkt.bm1422_magn_y);
        printf("%.6f,", pkt.bm1422_magn_z);

        printf("%.7f,", pkt.gps_lat_deg);
        printf("%.7f,", pkt.gps_lng_deg);
        printf("%.3f,", pkt.gps_alt_m);
        printf("%.3f,", pkt.gps_speed_mps);

        printf("%d,", pkt.gps_course);
        printf("%u", (unsigned)pkt.gps_num_sats);

        printf("\n");

        if (pkt.time_boot_ms > crop_start_ms)
        {
            fwrite(&pkt, sizeof(pkt), 1, fp_log_cropped);
        }
    }

    if (!feof(fp)) {
        // We hit an I/O error
        perror("fread");
        if (fp != stdin) fclose(fp);
        return 1;
    }

    if (nread != 0 && nread != sizeof(pkt)) {
        fprintf(stderr,
                "Warning: trailing %zu bytes at end of file (partial packet ignored)\n",
                nread);
    }

    if (fp != stdin) {
        fclose(fp);
    }

    // fclose(fp_log_cropped);

    return 0;
}