#pragma once

#include "math.h"
#include "AB_Struct_Storage.h"

float gravity(float altitude);

void snsr_Accel_Rotation(AB_Attitude_State& Attitude_State, AB_Snsrs& sensor, bool HG);

void Estimate_Horizontal_Velocity(AB_Attitude_State& AttState, AB_Vertical_State& VertState, AB_Horizontal_State& HorizState, float& est_north, float& est_east);

void Lever_Arm(Eigen::Vector3f& accel, Eigen::Vector3f& gyro, Eigen::Vector3f& r_arm);

float drag_coeff(float theta, float velocity, float);

float rho(float height);

float surfaceA(float angleOfDeployment);
