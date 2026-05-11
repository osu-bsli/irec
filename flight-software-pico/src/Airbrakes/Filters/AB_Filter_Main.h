#pragma once

#include "AB_Attitude_Filter.h"
#include "AB_Horizontal_Filter.h"
#include "AB_Vertical_Filter.h"

void AB_Filter_Initialize(AB_Filter_Main_Variables& Variables);
void AB_loop(AB_Filter_Main_Variables& Variables);
