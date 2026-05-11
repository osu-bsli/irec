#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

#define MASS 21 // kg
#define M_PI 3.14159265358979323846
void PredictDeploymentAngleInitialize();

float PredictDeploymentAngle(struct apogeeIC *ic, float targetApogee);

float PredictApogee(const struct apogeeIC ic);

struct apogeeIC
{
    float positionZ;
    float velocityZ;
    float thetaZ;
    float deploymentAngle;
};
