#pragma once

FSError sensors_setup();
FSError acquire_sensor_data(log_packet_latest *log_p);
uint8_t get_sensor_status_flags();