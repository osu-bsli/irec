#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

void AB_set_rocket_mass(float val);

float PredictDeploymentPct(struct apogeeIC ic, float targetApogee, int *out_itersReqd);
float PredictApogee(const struct apogeeIC ic, const float targetAirbrakeDeployment_pct);

float AB_drag_force(float deployment_pct, float vTotal_mps, float altitude_m);
float AB_drag_accel(float deployment_pct, float vTotal_mps, float altitude_m);

struct apogeeIC
{
    float altitude_m;
    float velocityZ_mps;
    float thetaZ_rad;
    float airbrakeDeployment_pct;
    float mass_kg;
};
