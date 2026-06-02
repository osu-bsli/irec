#pragma once

#include "telemetry.h"
#include "error.h"

void gps_setup();
FSError acquire_gps_data(log_packet_latest *log_p);
