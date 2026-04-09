#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

//Initializes and fills in the vertical state and neccessary variables for future calculations
void AB_Vertical_State_Initialization (
    AB_Vertical_State& sN, 
    AB_Vertical_Prediction& PredVars,
    AB_Vertical_Update_Baro& BaroVars,
    AB_Vertical_Update_GPS& GPSVars
);

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Vertical_State_Prediction (
    AB_Vertical_State& sN, 
    AB_Snsrs sensor, 
    AB_Vertical_Prediction& Variables,
    const bool HG
);

//Takes the calculation variables, current state, and new barometer data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_Baro (
    AB_Vertical_State& sN, 
    AB_Snsrs sensor, 
    AB_Vertical_Update_Baro& Variables,
    AB_Vertical_Prediction& UpVariables
);

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_GPS (
    AB_Vertical_State& sN, 
    AB_Snsrs sensor, 
    AB_Vertical_Update_GPS& Variables,
    AB_Vertical_Prediction& UpVariables
);
