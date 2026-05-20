#pragma once

#include "AB_Attitude_Filter.h"
#include "AB_Horizontal_Filter.h"
#include "AB_Vertical_Filter.h"

#define G_CONST 9.80665f

void AB_Filter_Initialize(AB_Filter& Variables);
void AB_Filter_Process(AB_Filter& filter, const AB_Filter_Inputs inputs, const AB_Settings settings);

const AB_Settings AB_Default_Settings();
