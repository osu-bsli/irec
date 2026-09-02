/*
 * bm1422.h
 *
 * Driver for 3-Axis Digital Magnetometer IC
 * 
 *  Created on: Jan 29, 2025
 *      Author: bsli
 */

#ifndef INC_FC_BM1422_H_
#define INC_FC_BM1422_H_

#include <stdbool.h>
#include <error.h>

struct fc_bm1422 {
	bool is_in_degraded_state;
};

struct fc_bm1422_data {
	float magn_x;
	float magn_y;
	float magn_z;
};

/* Functions */
FSError fc_bm1422_initialize(struct fc_bm1422 *device);
FSError fc_bm1422_process(struct fc_bm1422 *device, struct fc_bm1422_data *data);

#endif /* INC_FC_BM1422_H_ */
