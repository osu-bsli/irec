#pragma once
#include "AB_Struct_Storage.h"
#include "MathFunctions.h"

//Initializes and fills in the attitude state and neccessary variables for future calculations
void AB_Attitude_State_Initialization (
    AB_Attitude_State& sN, 
    AB_Attitude_Prediction& PredVars,
    AB_Attitude_Update_Accel& AccelVars,
    AB_Attitude_Update_GPS& GPSVars,
    AB_Attitude_Update_Mag& MagVars,
    AB_Attitude_Update_Drag& DragVars 
);

//Takes the calculation variables, current state, and new gyroscope data from the sensor struct and 
//computes the prediction step
void AB_Attitude_State_Prediction (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Prediction& Variables
);

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and computes 
//the update step
void AB_Attitude_State_Update_Accel (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Update_Accel& Variables,
    AB_Attitude_Prediction& UpVariables,
    const bool HG
);

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Attitude_State_Update_GPS (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Update_GPS& Variables,
    AB_Attitude_Prediction& UpVariables
);

//Takes the calculation variables, current state, and new magnometer data from the sensor struct and computes 
//the update step
void AB_Attitude_State_Update_Mag (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Update_Mag& Variables,
    AB_Attitude_Prediction& UpVariables
);

//preforms an update depending on velocity & drag
void AB_Attitude_Update_PseudoDrag(
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Vertical_State& vState,
    AB_Horizontal_State& hState,
    AB_Attitude_Update_Drag& Variables,
    AB_Attitude_Prediction& UpVariables
);