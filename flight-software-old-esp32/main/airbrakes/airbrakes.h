#pragma once

#include "AltimeterFilter.h"

#define AIRBRAKES_STAGE_STOWED 0
#define AIRBRAKES_STAGE_DEPLOYED 1
#define AIRBRAKES_STAGE_WAITING_TO_RETRACT 2
#define AIRBRAKES_STAGE_RETRACTED 3

void airbrakes_init();
AltimeterFilterOutput airbrakes_process(float pressure_mbar, float accel_z_mps2);
void airbrakes_check_for_retraction(AltimeterFilterOutput filter_out);
float apogee_ft_if_stowed(float altitude_m, float velocity_mps);
float apogee_ft_if_deployed_now(float altitude_m, float velocity_mps);