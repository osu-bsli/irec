/*
 * bmi323.h
 *
 *  Created on: Nov 12, 2023
 * @authors
 * - BSLI
 */

#pragma once

#include <stdbool.h>
#include <error.h>

/* struct */

struct fc_bmi323 {
	bool is_in_degraded_state;
};

struct fc_bmi323_data {
    /* datasheet pg. 22 */

    /* Acceleration - in Gs */
    float accel_x;
    float accel_y;
    float accel_z;
    bool accel_x_saturated;
    bool accel_y_saturated;
    bool accel_z_saturated;

    /* Gyroscope - in degrees/second */
    float gyro_x;
    float gyro_y;
    float gyro_z;
    bool gyro_x_saturated;
    bool gyro_y_saturated;
    bool gyro_z_saturated;

    /* Temperature - in Celcius */
    float temp;

    float time; /* sensor keeps timestamps for measurements (datasheet pg. 25) */
    uint32_t kernel_timestamp; /* in kernel ticks */
};

/* functions */
FSError fc_bmi323_initialize(struct fc_bmi323 *bmi323);
FSError fc_bmi323_process(struct fc_bmi323 *bmi323, struct fc_bmi323_data *data);
