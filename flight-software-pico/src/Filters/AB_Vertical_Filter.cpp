#include "AB_Vertical_Filter.h"

//Initializes and fills in the vertical state and neccessary variables for future calculations
void AB_Vertical_State_Initialization (
    AB_Vertical_State& sN, 
    AB_Vertical_Prediction& PredVars,
    AB_Vertical_Update_Baro& BaroVars,
    AB_Vertical_Update_GPS& GPSVars
) 
{
    //everything starts at 0
    sN.Altitude = 0.0f; //TODO - replace with initial gps reading
    sN.Velocity_Up = 0.0f;
    sN.Baro_Bias = 0.0f;

    //same, except for Q, where we assume model is clean, velocity is not as clean 
    //due to accel noise, and baro has a very small bias
    PredVars.F.setIdentity();
    PredVars.C.setIdentity();
    PredVars.Q.setZero();
    PredVars.Q(0, 0) = 0.001f;
    PredVars.Q(1, 1) = 0.1f;
    PredVars.Q(2, 2) = 0.0001f;

    //Same here, everthing to zero except for the barometer, which we trust a lot
    BaroVars.d.setZero();
    BaroVars.y.setZero();
    BaroVars.H.setZero();
    BaroVars.K.setZero();
    BaroVars.R(0, 0) = 6.6049f;
    BaroVars.sE.setZero();
    BaroVars.I.setIdentity();

    //Same here, everthing to zero except for the GPS, for the position we trust +- 5m, 
    //and velocity +- 0.2
    GPSVars.d.setZero();
    GPSVars.y.setZero();
    GPSVars.H.setZero();
    GPSVars.K.setZero();
    GPSVars.R.setIdentity();
    GPSVars.R(0, 0) = 5.0f;
    GPSVars.R(1, 1) = 0.5f;
    GPSVars.sE.setZero();
    GPSVars.I.setIdentity();
}

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and 
//computes the prediction step
void AB_Vertical_State_Prediction (
    AB_Vertical_State& sN, 
    AB_Snsrs sensor, 
    AB_Vertical_Prediction& Variables,
    const bool HG
) 
{
    if (HG == true) 
    {
        Variables.Q(0, 0) = 5.0f * 0.001f;
        Variables.Q(1, 1) = 5.0f * 0.1f;
        Variables.Q(2, 2) = 5.0f * 0.0001f;
    }

    else 
    {
        Variables.Q(0, 0) = 0.001f;
        Variables.Q(1, 1) = 0.1f;
        Variables.Q(2, 2) = 0.0001f;
    }

    Variables.dt = sensor.dt; //grabbing deltaT from the sensor struct.
    Variables.AccelZ = sensor.AccelerometerWorld(2); //grabing accelerometer Z from sensor struct
    Variables.AccelUp = Variables.AccelZ - gravity(sN.Altitude); //correcting Z acceleration for gravity
    Variables.oldVel = sN.Velocity_Up; //grabbing the old velocity
    sN.Altitude += Variables.oldVel * Variables.dt + 0.5f*Variables.AccelUp * Variables.dt * Variables.dt; //updating altitude, std kinematics
    sN.Velocity_Up += Variables.AccelUp * Variables.dt; //updating velocity, std kinematics
    //we dont change baro bias, as it is modeled as random walk
    //Now we have to update covariance, starting with jacobian. 
    // [    dalt/dalt,     dalt/dvel,     dalt/dbarbias]   
    // [    dvel/dalt,     dvel/dvel,     dvel/dbarbias]
    // [dbarbias/dalt, dbarbias/dvel, dbarbias/dbarbias]
    Variables.F.setIdentity();
    Variables.F(0, 1) = Variables.dt; //only weird one is the deivative of altitude wrt vel is dt.
    Variables.C = Variables.F * Variables.C * Variables.F.transpose() + Variables.Q; //updating covariance
}

//Takes the calculation variables, current state, and new barometer data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_Baro (
    AB_Vertical_State& sN, 
    AB_Snsrs sensor, 
    AB_Vertical_Update_Baro& Variables,
    AB_Vertical_Prediction& UpVariables
) 
{
    //difference between baro reading and altitude + bias of the barometer
    Variables.y << (sensor.Barometer - (sN.Altitude + sN.Baro_Bias)); 

    //Now we find out H, or how the state effects the measurement
    //[dbaro/dAlt, dBaro/dvel, dBaro/dBaroBias] depends on altitude and the bias!
    Variables.H << 1.0f, 0.0f, 1.0f;

    //Now we find the kalman gain, K
    Variables.K = UpVariables.C * Variables.H.transpose() * (Variables.H * UpVariables.C * Variables.H.transpose() + Variables.R).inverse();

    //We also find the error state
    Variables.sE = Variables.K * Variables.y;

    //we add those corrections to the nominal state
    sN.Altitude += Variables.sE(0, 0);
    sN.Velocity_Up += Variables.sE(1, 0);
    sN.Baro_Bias += Variables.sE(2, 0);

    //finally, we update the covariance
    UpVariables.C = (Variables.I - Variables.K * Variables.H) * UpVariables.C;
}

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Vertical_State_Update_GPS (
    AB_Vertical_State& sN, 
    AB_Snsrs sensor, 
    AB_Vertical_Update_GPS& Variables,
    AB_Vertical_Prediction& UpVariables
) 
{
    //difference between GPS altitude and altitude in the state
    Variables.y << (sensor.GPS(2) - sN.Altitude), (sensor.GPS(5) - sN.Velocity_Up); 

    //Now we find out H, or how the state effects the measurement
    //[dGPS/dAlt, dGPS/dvel, dGPS/dBaroBias] depends on altitude only
    Variables.H.setZero();
    Variables.H(0, 0) = 1.0f;
    Variables.H(1, 1) = 1.0f;

    //Now we find the kalman gain, K
    Variables.K = UpVariables.C * Variables.H.transpose() * (Variables.H * UpVariables.C * Variables.H.transpose() + Variables.R).inverse();

    //We also find the error state
    Variables.sE = Variables.K * Variables.y;

    //we add those corrections to the nominal state
    sN.Altitude += Variables.sE(0, 0);
    sN.Velocity_Up += Variables.sE(1, 0);
    sN.Baro_Bias += Variables.sE(2, 0);

    //finally, we update the covariance
    UpVariables.C = (Variables.I - Variables.K * Variables.H) * UpVariables.C;
}