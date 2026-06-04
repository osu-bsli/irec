#include "testing.h"
#include "nomad_test_flight_2026-4-11_cropped.logv3.h"

#include <cstring>

#include <SerialUSB.h>

// check that length of log evenly divides by log packet size
static_assert(log_cropped_logv3_len / sizeof(log_packet_v3) * sizeof(log_packet_v3) == log_cropped_logv3_len);
const int log_len = log_cropped_logv3_len / sizeof(log_packet_v3);

int log_i;

FSError acquire_sensor_data_prerecorded(log_packet_v3 *log_p_out)
{
    log_packet_v3 *log = (log_packet_v3 *)log_cropped_logv3;

    log_packet_v3 log_p = log[log_i];

    if (log_i < log_len - 1)
    {
        log_i++;
    }

    *log_p_out = log_p;

    return SUCCESS;
}

/*
 * Reads ONE log packet from serial for HITL testing purposes.
 * Blocks until one packet is fully received.
 */
static uint8_t packet_rx_buf[sizeof(log_packet_v3)] = {0};
static uint8_t packet_rx_buf_i = 0;
FSError acquire_sensor_data_from_serial(log_packet_v3 *log_p_out)
{
    while (packet_rx_buf_i < sizeof(log_packet_v3))
    {
        while (!Serial.available())
        {
        }

        uint8_t b = Serial.read();
        if (packet_rx_buf_i < LOG_PACKET_MAGIC_LEN)
        {
            if (LOG_PACKET_MAGIC[packet_rx_buf_i] == b)
            {
                packet_rx_buf[packet_rx_buf_i] = b;
                packet_rx_buf_i++;
            }
            else
            {
                // Check if the mismatched byte starts a new sequence
                if (LOG_PACKET_MAGIC[0] == b)
                {
                    packet_rx_buf[0] = b;
                    packet_rx_buf_i = 1;
                }
                else
                {
                    packet_rx_buf_i = 0;
                }
            }
        }
        else
        {
            packet_rx_buf[packet_rx_buf_i] = b;
            packet_rx_buf_i++;
        }
    }

    packet_rx_buf_i = 0;

    memcpy(log_p_out, packet_rx_buf, sizeof(log_packet_v3));

    // TODO sanity check that packets aren't dropped (maybe check that time_boot_ms always increments by 10? and make tritone wee woo wee woo sound if not)

    return SUCCESS;
}