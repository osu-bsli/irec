#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

#define MASS 21 // kg

float PredictDeploymentPct(struct apogeeIC ic, float targetApogee, int *out_itersReqd);

float PredictApogee(const struct apogeeIC ic);

struct apogeeIC
{
    float altitude_m;
    float velocityZ_mps;
    float thetaZ_rad;
    float airbrakeDeployment_pct;
};
