#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

#define MASS 20 //kg
#define M_PI 3.14159265358979323846
void PredictDeploymentAngleInitialize(AB_Predict_Deployment_Angle_Variables& Variables);

float PredictDeploymentAngle(float* apogeeIC, AB_Predict_Deployment_Angle_Variables& Variables, AB_Predict_Apogee_Variables& AppVariables);

float PredictApogee(float* apogeeIC, AB_Predict_Apogee_Variables& Variables);

