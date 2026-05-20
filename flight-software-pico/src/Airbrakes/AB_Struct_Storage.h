#pragma once

#include "Eigen/Dense"
using namespace Eigen;
// Input Variables come from struct. The purpose of this file is to remove all dynamic and on the fly initialized
// variables from the code, so can properly keep track of the maximum allowed memory use.

struct AB_Filter_Inputs
{                                             // Struct containing all sensor data
    Matrix<float, 3, 1> Accelerometer_mps2;   // Accel(m/s^2) X, Y, Z
    Matrix<float, 3, 1> AccelerometerHG_mps2; // Accel(m/s^2) X, Y, Z
    Matrix<float, 3, 1> Gyroscope_radps;      // AngularV(rad/s) X, Y, Z
    Matrix<float, 3, 1> Magnetometer;         // Field(uT) X, Y, Z
    Matrix<float, 3, 1> GPS_Position_m;       // position(m) X, Y, Z
    Matrix<float, 3, 1> GPS_Velocity_mps;     // velocity(m/s) X, Y, Z
    float Barometer_m;                        // altitude(m) Z
    float dt;                                 // time between last sensor change, needs to be updated every time.
    bool IgnoreBaro;
};

struct AB_Snsrs_prevData
{                            // Struct containing all sensor data
    Matrix<float, 3, 1> GPS_Position_m;       // position(m) X, Y, Z
    Matrix<float, 3, 1> GPS_Velocity_mps;     // velocity(m/s) X, Y, Z
    float Barometer;
};

struct AB_Snsrs_booleans
{             // Struct containing all sensor data
    bool GPS_updated; // position(m) X, Y, Z and velocity(m/s) X, Y, Z
};

struct AB_Attitude_State
{                                       // struct containing the state for the rocket's attitude
    Quaternionf Quaternion_Body_To_ENU; // quaternion describing rotation from body frame to ENU
    Matrix<float, 3, 1> Gyro_Bias;      // bias of the gyroscope
    Matrix<float, 3, 1> Accel_Bias;     // bias of the accelerometer
};

struct AB_Vertical_State
{                         // struct containing the state for the rocket's vertical motion
    float Altitude_m;     // current height of the rocket relative to starting height
    float VelocityUp_mps; // current velocity of the rocket relative to starting velocity
    float Baro_Bias;      // barometer bias
    Matrix<float, 3, 3> C;
};

struct AB_Horizontal_State
{                            // struct containing the state for the rocket's horizontal motion
    float Position_East;     // position in East direction relative to starting position
    float Position_North;    // position in North direction relative to starting position
    float VelocityEast_mps;  // Velocity in East direction relative to starting position
    float VelocityNorth_mps; // Velocity in North direction relative to starting position
    Matrix<float, 4, 4> C;
};

struct AB_Attitude_Prediction
{ // prediction variables(uses gyro XYZ)
    Matrix<float, 9, 9> C;
    Matrix<float, 9, 9> Q;
};

enum AB_Filter_Flight_Stage
{
    AB_Filter_Flight_Stage_PAD,
    AB_Filter_Flight_Stage_BURNING,
    AB_Filter_Flight_Stage_BURNOUT,
    AB_Filter_Flight_Stage_APOGEE,
};

struct AB_Filter
{
    // structs for states and inputs
    AB_Snsrs_prevData PrevSensors;
    AB_Snsrs_booleans Flags;
    AB_Vertical_State VertState;
    AB_Horizontal_State HorizState;
    AB_Attitude_State AttState;

    // filter variables
    AB_Attitude_Prediction AB_Att_Pred;

    // variables for runtime
    float max_apogee;
    AB_Filter_Flight_Stage flight_stage;
    float time_since_launch;
    int mag_calibration_count;
    int c1;
    bool mag_calibrated;

    // vectors for runtime
    Eigen::Vector3f R0;
    Eigen::Vector3f Rdot;
    Eigen::Vector3f AccelBias;
    Eigen::Vector3f R;
    Eigen::Vector3f mag_calibration_sum;

    // debug variables
    Matrix<float, 3, 1> AccelerationWorld;
};

struct AB_Settings
{
    Matrix<float, 3, 3> VertHighGQ;
    Matrix<float, 3, 3> VertLowGQ;

    Matrix<float, 1, 1> VertBaroR;
    Matrix<float, 2, 2> VertGpsR;

    float Mass_kg;
    float GroundTemp_C;
    float DeploymentRate_pctPerS;
    float TargetApogee_m;
};
