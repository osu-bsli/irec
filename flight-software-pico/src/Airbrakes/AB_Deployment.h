#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

float PredictDeploymentPct(struct apogeeIC ic, int *out_itersReqd, const AB_Settings& settings);
float PredictApogee(const struct apogeeIC ic, float targetAirbrakeDeployment_pct, const AB_Settings& settings);

float AB_drag_force(float deployment_pct, float vTotal_mps, float altitude_m, const AB_Settings& settings);
float AB_drag_accel(float deployment_pct, float vTotal_mps, float altitude_m, const AB_Settings& settings);

/* Build an apogeeIC from the current navigation filter state.
   Shared by the flight computer runtime loop and any offline replay that
   calls PredictDeploymentPct / PredictApogee after AB_Filter_Process. */
apogeeIC filter_to_apogee_ic(const AB_Filter &filter);

struct apogeeIC
{
    float altitude_m;
    float velocityZ_mps;
    float thetaZ_rad;
    float airbrakeDeployment_pct;
};
