#include "MathFunctions.h"
#include <utility.h>

#include "pico.h"

float __not_in_flash_func(gravity)(float altitude) 
{
    //ohio's average gravity at SL, plus adjustment for our altitude, about .28% diff at apogee
    return (9.802-(altitude*3.086e-6));
}

Matrix<float, 3, 1> __not_in_flash_func(RotateAccelToWorldFrame)(AB_Attitude_State& Attitude_State, AB_SensorData& sensor, bool HG) 
{
    //rotates the accelertion data from the sensor to the world frame 
    //for the vertical & horizontal filters.
    Vector3f Accel;
    if (HG == true) 
    {
        Accel = sensor.AccelerometerHG_mps2; //grabbing vector from sensor struct
    }
    else 
    {
        Accel = sensor.Accelerometer_mps2; //grabbing vector from sensor struct
    }
    Vector3f Accel_Unbiased;
    //subtract accel bias
    Accel_Unbiased(0) = Accel(0) - Attitude_State.Accel_Bias(0);
    Accel_Unbiased(1) = Accel(1) - Attitude_State.Accel_Bias(1);
    Accel_Unbiased(2) = Accel(2) - Attitude_State.Accel_Bias(2);
    Vector3f Accel_World = Attitude_State.Quaternion_Body_To_ENU * Accel_Unbiased;
    
    return Accel_World;
}

//Velocity estimate from vertical(only used when gps is off to gate divergance)
void __not_in_flash_func(Estimate_Horizontal_Velocity)(AB_Attitude_State& AttState, AB_Vertical_State& VertState, AB_Horizontal_State& HorizState, float& est_north, float& est_east) 
{
    Quaternionf& q = AttState.Quaternion_Body_To_ENU;
    
    // we use quat to calculate which direction the nose is going in ENU
    float nose_north = 2.0f * (q.x() * q.z() + q.w() * q.y());
    float nose_east = 2.0f * (q.y() * q.z() - q.w() * q.x());
    float nose_up = 1.0f - 2.0f * (q.x() * q.x() + q.y() * q.y());

    // Take E and N components
    float total_speed = VertState.Velocity_Up / nose_up;
    
    est_north = total_speed * nose_north;
    est_east = total_speed * nose_east;
    if (nose_up < 0.1) 
    {
        est_north = HorizState.Velocity_North; 
        est_east = HorizState.Velocity_East; 
    }
}

//apporimates the vector from the rocket's true center of mass to the sensor stack; must calculate this using a seperate script
// we will rotate rocket with fuel about com and calc data to calibrate, as well as without fuel. 
void __not_in_flash_func(Lever_Arm)(Eigen::Vector3f& accel, Eigen::Vector3f& gyro, Eigen::Vector3f& r_arm) 
{
    Eigen::Vector3f a_C = gyro.cross(gyro.cross(r_arm));
    accel -= a_C;
}

/*
 * Calculates theoretical coefficient of drag (Cd) from airbrake deployment percentage, velocity, and altitude.
 * 
 * Calculation based on simulation data from the aerodynamics team. 
 */
//function that we will need to work on before test flight!
float __not_in_flash_func(drag_coeff)(float ab_deployment_pct, float velocity_mps, float altitude_m, float ground_level_temp_celcius)
{
    float ground_level_temp_kelvin = ground_level_temp_celcius + 273.15;
    float T_kelvin = ground_level_temp_kelvin - 0.00649 * altitude_m; // temperature in Kelvin
    float a = CHECK_NAN(sqrt(fabs(1.4*287.0529*T_kelvin))); // speed of sound

    float Mach = CHECK_NAN(velocity_mps/a);
    float Cd  = 0.4792 + -0.3960 * Mach + 0.00091 * ab_deployment_pct + 0.2975 * Mach * Mach - 0.000002 * ab_deployment_pct * ab_deployment_pct - 0.000211 * Mach * ab_deployment_pct;

    if (Cd > 0.5) {
        Cd = 0.5;
    }
    else if (Cd < 0.01) {
        Cd = 0.01;
    }
    return Cd;
}

//calculates air density from standard atmosphere table
float __not_in_flash_func(rho_kg_per_m3)(float altitude_m)
{
    if (altitude_m < 0) 
    {
        altitude_m = 0;
    }
    float T_celcius = 15.04 - 0.00649 * altitude_m;
    float p = 101.29 * pow((T_celcius + 273.1) / 288.08, 5.256);
    return CHECK_NAN(p / (0.2869 * (T_celcius + 273.1)));
}

//calculates surface area using constant rocket diam and a linear surface function.
float __not_in_flash_func(surfaceA)(float angleOfDeployment)
{
    //keep in mind angle is not really an angle, but a percentage.
    return 0.0189784246051 + angleOfDeployment * 0.0035;
}
