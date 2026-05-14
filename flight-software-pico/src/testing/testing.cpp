#include "testing.h"
#include "nomad_test_flight_2026-4-11_cropped.logv3.h"

// check that length of log evenly divides by log packet size
static_assert(log_cropped_logv3_len / sizeof(log_packet_v3) * sizeof(log_packet_v3) == log_cropped_logv3_len);
const int log_len = log_cropped_logv3_len / sizeof(log_packet_v3);

int log_i;

FSError acquire_sensor_data_prerecorded(log_packet_v3 *log_p_out)
{
    log_packet_v3 *log = (log_packet_v3*)log_cropped_logv3;

    log_packet_v3 log_p = log[log_i];

    if (log_i < log_len - 1)
    {
        log_i++;
    }

    *log_p_out = log_p;

    return SUCCESS;
}