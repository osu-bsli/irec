/**
 * adxl375.h
 *
 * ADXL375 accelerometer driver.
 */

/* "#pragma once" prevents this header file from being included multiple times in a C file */
#pragma once

#include <stdbool.h>
#include <error.hpp>

/*
 * Header files are for sharing things that other C files need.
 * Register addresses should go in adxl375.c and not this header file because other C files do not need to see them.
 *
 * Header files should contain the absolute bare minimum that other files need to see.
 */

// TODO: Is it appropriate to keep store the most recently read acceleration values
// TODO: in the sensor struct? Might be better to make the API user responsible for that
struct fc_adxl375
{
  bool is_in_degraded_state;
};

struct fc_adxl375_data
{
  float accel_x;
  float accel_y;
  float accel_z;
};

/*
 * The public-facing API should be as simple as possible.
 * Consider what the flight software needs from the sensor and design the bare minimum API to provide that.
 */
FSError fc_adxl375_initialize(struct fc_adxl375 *device);
// TODO: Change process to get_data and add struct pointer param that data will be placed into
FSError fc_adxl375_process(struct fc_adxl375 *device, struct fc_adxl375_data *data);
