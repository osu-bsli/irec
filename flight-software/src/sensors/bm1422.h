/*
 * bm1422.h
 *
 *  Created on: Jan 29, 2025
 *      Author: bsli
 */

#ifndef INC_FC_BM1422_H_
#define INC_FC_BM1422_H_

#include <stdbool.h>
#include <esp_err.h>

struct fc_bm1422 {
	bool is_in_degraded_state;
};

struct fc_bm1422_data {
	float magn_x;
	float magn_y;
	float magn_z;
};

/* Functions */
esp_err_t fc_bm1422_initialize(struct fc_bm1422 *device);
esp_err_t fc_bm1422_process(struct fc_bm1422 *device, struct fc_bm1422_data *data);

#endif /* INC_FC_BM1422_H_ */
