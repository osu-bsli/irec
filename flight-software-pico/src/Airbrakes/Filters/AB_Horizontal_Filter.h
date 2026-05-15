#pragma once

#include "AB_Struct_Storage.h"
#include "MathFunctions.h"
 
//Initializes and fills in the horizontal state and neccessary variables for future calculations
void AB_Horizontal_State_Initialization (
    AB_Horizontal_State& sN
);

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Horizontal_State_Prediction (
    AB_Horizontal_State& sN, 
    AB_SensorData sensor,
    const Vector<float, 3> accelerationWorld,
    const bool HG
);

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Horizontal_State_Update_GPS (
    AB_Horizontal_State& sN, 
    const AB_SensorData sensor
);