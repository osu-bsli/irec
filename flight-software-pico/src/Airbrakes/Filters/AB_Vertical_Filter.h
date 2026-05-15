#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

//Initializes and fills in the vertical state and neccessary variables for future calculations
void AB_Vertical_State_Initialization (
    AB_Vertical_State& sN
);

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Vertical_State_Prediction (
    AB_Vertical_State& sN,
    const AB_SensorData sensor,
    const AB_Settings settings,
    const Matrix<float, 3, 1> accelerationWorld,
    const bool highG
);

//Takes the calculation variables, current state, and new barometer data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_Baro (
    AB_Vertical_State& sN,
    AB_SensorData sensor,
    const AB_Settings settings
);

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_GPS (
    AB_Vertical_State& sN,
    AB_SensorData sensor,
    const AB_Settings settings
);
