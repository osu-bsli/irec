#include "AB_Horizontal_Filter.h"

//Initializes and fills in the horizontal state and neccessary variables for future calculations
void AB_Horizontal_State_Initialization (
    AB_Horizontal_State& sN, 
    AB_Horizontal_Prediction& PredVars,
    AB_Horizontal_Update_GPS& GPSVars
) 
{
    sN.Position_East = 0.0f; //TODO - replace with initial gps reading
    sN.Position_North = 0.0f; //TODO - replace with initial gps reading
    sN.Velocity_East = 0.0f; //TODO - replace with initial gps reading
    sN.Velocity_North = 0.0f; //TODO - replace with initial gps reading

    //Fairly confident in integration for position, less confident with velocity & wind
    PredVars.F.setIdentity();
    PredVars.C.setIdentity();
    PredVars.Q.setZero();
    PredVars.Q(0, 0) = 0.001f;
    PredVars.Q(1, 1) = 0.001f;
    PredVars.Q(2, 2) = 0.1f;
    PredVars.Q(3, 3) = 0.1f;

    //Everthing to zero except for the GPS, for the position we trust +- 5m, 
    //and velocity +- 0.2
    GPSVars.d.setZero();
    GPSVars.y.setZero();
    GPSVars.H.setZero();
    GPSVars.K.setZero();
    GPSVars.R.setIdentity();
    GPSVars.R(0, 0) = 5.0f;
    GPSVars.R(1, 1) = 5.0f;
    GPSVars.R(2, 2) = 0.5f;
    GPSVars.R(3, 3) = 0.5f;
    GPSVars.sE.setZero();
    GPSVars.I.setIdentity();
}

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Horizontal_State_Prediction (
    AB_Horizontal_State& sN, 
    AB_Snsrs sensor, 
    AB_Horizontal_Prediction& Variables,
    const bool HG
) 
{
    if (HG == true) 
    {
        Variables.Q(0, 0) = 5.0f*0.001f;
        Variables.Q(1, 1) = 5.0f*0.001f;
        Variables.Q(2, 2) = 5.0f*0.1f;
        Variables.Q(3, 3) = 5.0f*0.1f;
    }

    else 
    {
        Variables.Q(0, 0) = 0.001f;
        Variables.Q(1, 1) = 0.001f;
        Variables.Q(2, 2) = 0.1f;
        Variables.Q(3, 3) = 0.1f;
    }

    Variables.dt = sensor.dt; //grabbing deltaT from the sensor struct.
    Variables.AccelE = sensor.AccelerometerWorld(0); //grabbing accelerometer E from sensor struct
    Variables.AccelN = sensor.AccelerometerWorld(1); //grabbing accelerometer N from sensor struct
    Variables.oldEVel = sN.Velocity_East; //grabbing the old velocity
    Variables.oldNVel = sN.Velocity_North; //grabbing the old velocity
    sN.Position_East += Variables.oldEVel*Variables.dt + 0.5f*(Variables.AccelE)*Variables.dt*Variables.dt; //updating position, std kinematics
    sN.Position_North += Variables.oldNVel*Variables.dt + 0.5f*(Variables.AccelN)*Variables.dt*Variables.dt; //updating position, std kinematics
    sN.Velocity_East += (Variables.AccelE)*Variables.dt; //updating velocity, std kinematics
    sN.Velocity_North += (Variables.AccelN)*Variables.dt; //updating velocity, std kinematics
    //Now we have to update covariance, starting with jacobian. 
    // [dposE/dposE,     dposE/dposN,     dposE/dvelE    dposE/dvelN]  [1 0 dt 0]
    // [dposN/dposE,     dposN/dposN,     dposN/dvelE    dposN/dvelN]  [0 1 dt 0]
    // [dvelE/dposE,     dvelE/dposN,     dvelE/dvelE    dvelE/dvelN]  [0 0 1  0]
    // [dvelN/dposE,     dvelN/dposN,     dvelN/dvelE    dvelN/dvelN]  [0 0 0  1]
    Variables.F.setIdentity();
    Variables.F(0, 2) = Variables.dt; //derivative of pos wrt velocity is dt
    Variables.F(1, 3) = Variables.dt; //derivative of pos wrt velocity is dt
    Variables.C = Variables.F * Variables.C * Variables.F.transpose() + Variables.Q; //updating covariance
}

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Horizontal_State_Update_GPS (
    AB_Horizontal_State& sN, 
    AB_Snsrs sensor, 
    AB_Horizontal_Update_GPS& Variables,
    AB_Horizontal_Prediction& UpVariables
) {
    //difference between position/velocity reading in NE and gps reading
    Variables.y << (sensor.GPS(0) - (sN.Position_East)), 
    (sensor.GPS(1) - (sN.Position_North)), 
    (sensor.GPS(3) - (sN.Velocity_East)), 
    (sensor.GPS(4) - (sN.Velocity_North)); 

    //Now we find out H, or how the state effects the measurement
    //[dbaro/dAlt, dBaro/dvel, dBaro/dBaroBias] depends on altitude and the bias!
    //Depends on the position and the velocity
    // [ dGPSE/dposE,      dGPSE/dposN,      dGPSE/dvelE,     dGPSE/dvelN]  [1 0 dt 0]
    // [ dGPSN/dposE,      dGPSN/dposN,      dGPSN/dvelE,     dGPSN/dvelN]  [0 1 dt 0]
    // [dGPSVE/dposE,     dGPSVE/dposN,     dGPSVE/dvelE,    dGPSVE/dvelN]  [0 0 1  0]
    // [dGPSVN/dposE,     dGPSVN/dposN,     dGPSVN/dvelE,    dGPSVN/dvelN]  [0 0 0  1]
    Variables.H.setZero();
    Variables.H(0, 0) = 1.0f;
    Variables.H(1, 1) = 1.0f;
    Variables.H(2, 2) = 1.0f;
    Variables.H(3, 3) = 1.0f;

    //Now we find the kalman gain, K
    Variables.K = UpVariables.C * Variables.H.transpose() * (Variables.H * UpVariables.C * Variables.H.transpose() + Variables.R).inverse();

    //We also find the error state
    Variables.sE = Variables.K * Variables.y;

    //we add those corrections to the nominal state
    sN.Position_East += Variables.sE(0, 0);
    sN.Position_North += Variables.sE(1, 0);
    sN.Velocity_East += Variables.sE(2, 0);
    sN.Velocity_North += Variables.sE(3, 0);

    //finally, we update the covariance
    UpVariables.C = (Variables.I - Variables.K * Variables.H) * UpVariables.C;
}