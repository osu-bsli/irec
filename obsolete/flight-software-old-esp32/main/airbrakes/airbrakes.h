#pragma once

#include "AltimeterFilter.h"

#define AIRBRAKES_STAGE_STOWED 0
#define AIRBRAKES_STAGE_DEPLOYED 1
#define AIRBRAKES_STAGE_WAITING_TO_RETRACT 2
#define AIRBRAKES_STAGE_RETRACTED 3

void airbrakes_setup();
void airbrakes_zeroing();
AltimeterFilterOutput airbrakes_process(float pressure_mbar, float accel_z_mps2);
void airbrakes_check_for_retraction(AltimeterFilterOutput filter_out);
float apogee_ft_if_stowed(float altitude_m, float velocity_mps);
float apogee_ft_if_deployed_now(float altitude_m, float velocity_mps);
void fully_retract_airbrakes();
void fully_deploy_airbrakes();
void airbrakes_burn_in_test_loop();
void airbrakes_test_interface_serial_loop();