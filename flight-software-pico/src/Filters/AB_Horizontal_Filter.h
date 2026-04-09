#pragma once

#include "AB_Struct_Storage.h"
#include "MathFunctions.h"
 
//Initializes and fills in the horizontal state and neccessary variables for future calculations
void AB_Horizontal_State_Initialization (
    AB_Horizontal_State& sN, 
    AB_Horizontal_Prediction& PredVars,
    AB_Horizontal_Update_GPS& GPSVars
);

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Horizontal_State_Prediction (
    AB_Horizontal_State& sN, 
    AB_Snsrs sensor, 
    AB_Horizontal_Prediction& Variables,
    const bool HG
);

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Horizontal_State_Update_GPS (
    AB_Horizontal_State& sN, 
    AB_Snsrs sensor, 
    AB_Horizontal_Update_GPS& Variables,
    AB_Horizontal_Prediction& UpVariables
);