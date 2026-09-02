#pragma once

#include "math.h"
#include "AB_Struct_Storage.h"

float gravity(float altitude);

Matrix<float, 3, 1> RotateAccelToWorldFrame(const AB_Attitude_State& Attitude_State, const AB_Filter_Inputs& sensor, bool HG);

void Estimate_Horizontal_Velocity(AB_Attitude_State& AttState, AB_Vertical_State& VertState, AB_Horizontal_State& HorizState, float& est_north, float& est_east);

void Lever_Arm(Eigen::Vector3f& accel, Eigen::Vector3f& gyro, Eigen::Vector3f& r_arm);

float drag_coeff(float ab_deployment_pct, float velocity_mps, float altitude_m, float ground_level_temp_celcius);

float rho_kg_per_m3(float altitude_m);

float surfaceA(float angleOfDeployment);
