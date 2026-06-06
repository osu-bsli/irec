#include <cstdio>
/*
 * SITL sensor adapter.
 *
 * Replaces the PC sensor stub (stubs/internal/sensors.cpp) for the SITL build.
 * Instead of reading I2C sensors, it pulls one LogPacketV3 frame from the
 * in-memory serial channel (reusing the firmware's own
 * acquire_sensor_data_from_serial) and writes the commanded deployment
 * percentage back to the host — exactly the USB-serial HITL protocol, just over
 * the in-process channel. No real sensor drivers are pulled in.
 */

#include "sensors.h"          /* FSError, log_packet_latest, sensors API */
#include "testing/testing.h"  /* acquire_sensor_data_from_serial */
#include "Serial.h"

/* Commanded deployment percentage, set by deploy_task in main.cpp. */
extern uint8_t g_airbrake_pct;

FSError sensors_setup()
{
    return SUCCESS;
}

FSError acquire_sensor_data(log_packet_latest *log_p)
{
    FSError status = acquire_sensor_data_from_serial(log_p);
    /* Reply to the host with the latest commanded deployment percentage. */
    Serial.write(g_airbrake_pct);
    return status;
}

uint8_t get_sensor_status_flags()
{
    return 0;
}
