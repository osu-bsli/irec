/*
 * bm1422.h
 *
 *  Created on: Jan 29, 2025
 *      Author: bsli
 */

#ifndef INC_FC_BM1422_H_
#define INC_FC_BM1422_H_

#include "stm32h7xx_hal.h"
#include <FreeRTOS.h>
#include <semphr.h>
#include <stdbool.h>

struct fc_bm1422 {
	I2C_HandleTypeDef *i2c_handle;
	SemaphoreHandle_t *i2c_semaphore;
	bool is_in_degraded_state;
};

struct fc_bm1422_data {
	float magn_x;
	float magn_y;
	float magn_z;
};

/* Functions */
HAL_StatusTypeDef fc_bm1422_initialize(struct fc_bm1422 *device, I2C_HandleTypeDef *i2c_handle, SemaphoreHandle_t *i2c_semaphore);
HAL_StatusTypeDef fc_bm1422_process(struct fc_bm1422 *device, struct fc_bm1422_data *data);

#endif /* INC_FC_BM1422_H_ */
