#include "AB_Filter_Main.h"
#include <iostream>
using namespace std;

void AB_Filter_Initialize(AB_Filter_Main_Variables& Variables) 
{
    Variables.apogee = false;
    Variables.burning = false;
    Variables.burnout = false;
    Variables.mag_calibrated = false;
    Variables.time_since_launch = 0.0f;
    Variables.mag_calibration_count = 0;
    Variables.mag_calibration_sum << 0, 0, 0;

    Variables.R0 << -0.04780f, 0.09582f, 3.70342f;
    Variables.Rdot << 0.0f, 0.0f, -1.90235f;
    Variables.R = Variables.R0;
    Variables.AccelBias << 0.0f, 0.0f, 0.0f;
    Variables.Sensors.Mag_Reference << -2.3296f, 20.3722f, -47.1803f;
    Variables.Sensors.Mag_Reference.normalize();

    Variables.PrevSensors.Accelerometer.setZero();
    Variables.PrevSensors.AccelerometerHG.setZero();
    Variables.PrevSensors.Gyroscope.setZero();
    Variables.PrevSensors.Magnetometer.setZero();
    Variables.PrevSensors.GPS.setZero();
    Variables.PrevSensors.Barometer = 0.0f;
    Variables.Flags.Accelerometer = false;
    Variables.Flags.AccelerometerHG = false;
    Variables.Flags.Gyroscope = false;
    Variables.Flags.Magnetometer = false;
    Variables.Flags.GPS = false;
    Variables.Flags.Barometer = false;
    Variables.highG = false;
    AB_Attitude_State_Initialization (
        Variables.AttState, 
        Variables.AB_Att_Pred, 
        Variables.AB_Att_UP_Accel, 
        Variables.AB_Att_UP_GPS, 
        Variables.AB_Att_UP_Mag,
        Variables.AB_Att_UP_Drag
    );
    AB_Vertical_State_Initialization (
        Variables.VertState, 
        Variables.AB_Vert_Pred, 
        Variables.AB_Vert_UP_Baro, 
        Variables.AB_Vert_UP_GPS
    );
    AB_Horizontal_State_Initialization (
        Variables.HorizState, 
        Variables.AB_Horiz_Pred, 
        Variables.AB_Horiz_UP_GPS
    );
}

void AB_loop(AB_Filter_Main_Variables& Variables) 
{

    //Then we see if new data has come in, and if it did, let the filter know.
    if (Variables.PrevSensors.Accelerometer.norm() != Variables.Sensors.Accelerometer.norm()) 
    {
        Variables.Flags.Accelerometer = true;
    }

    if (Variables.PrevSensors.AccelerometerHG.norm() != Variables.Sensors.AccelerometerHG.norm()) 
    {
        Variables.Flags.AccelerometerHG = true;
    }

    if (Variables.PrevSensors.Gyroscope.norm() != Variables.Sensors.Gyroscope.norm()) 
    {
        Variables.Flags.Gyroscope = true;
    }

    if (Variables.PrevSensors.Magnetometer.norm() != Variables.Sensors.Magnetometer.norm()) 
    {
        Variables.Flags.Magnetometer = true;
    }  

    if (Variables.PrevSensors.GPS.norm() != Variables.Sensors.GPS.norm()) 
    {
        Variables.Flags.GPS = true;
    }  

    if (Variables.PrevSensors.Barometer != Variables.Sensors.Barometer) 
    {
        Variables.Flags.Barometer = true;
    }

    if (Variables.Sensors.Accelerometer.norm() > 1.2f*9.81f) 
    {
        Variables.highG = true;
    }

    else 
    {
        Variables.highG = false;
    }

    if (Variables.highG == true) 
    {
        Variables.accel_z_current = Variables.Sensors.AccelerometerHG.z();
    }

    else 
    {
        Variables.accel_z_current = Variables.Sensors.Accelerometer.z();
    }

    if (Variables.burning == false && Variables.burnout == false && Variables.apogee == false) 
    {
        if (Variables.accel_z_current > 2.0*9.802f) 
        {
            Variables.burning = true;
        }
    }

    if (Variables.burning == true) 
    {
        Variables.time_since_launch += Variables.Sensors.dt;

        if (Variables.accel_z_current < 1.0f) 
        {
            Variables.burning = false;
            Variables.burnout = true;
        }
    } 

    if (Variables.burnout == true && Variables.apogee == false) 
    {
        if (Variables.VertState.Velocity_Up < -1.0f) 
        {
            Variables.apogee = true;
            Variables.max_apogee = Variables.VertState.Altitude;
        }
    }
    

    if (Variables.burning == true) 
    {
        Variables.R = Variables.R0 + (Variables.Rdot * Variables.time_since_launch);
    } 

    Variables.Sensors.AccelerometerHG -= Variables.AccelBias;

    Lever_Arm(Variables.Sensors.Accelerometer, Variables.Sensors.Gyroscope, Variables.R);
    Lever_Arm(Variables.Sensors.AccelerometerHG, Variables.Sensors.Gyroscope, Variables.R);

    //Main filter loop. Start with attitude filter
    if (Variables.Flags.Gyroscope == true) 
    {
        AB_Attitude_State_Prediction(Variables.AttState, Variables.Sensors, Variables.AB_Att_Pred);
    }

    if (Variables.highG == true) 
    {
        if (Variables.Flags.AccelerometerHG == true) 
        {
            if (Variables.Sensors.AccelerometerHG.norm() > 8.0f && Variables.Sensors.AccelerometerHG.norm() < 11.0f && Variables.Sensors.AccelerometerHG.z() < 2.1f*9.802f) 
            {
                if (Variables.VertState.Velocity_Up < 0.3f) 
                {
                    AB_Attitude_State_Update_Accel(Variables.AttState, Variables.Sensors, Variables.AB_Att_UP_Accel, Variables.AB_Att_Pred, Variables.highG);
                }
            }
        }
    }

    else if (Variables.apogee == true && Variables.VertState.Altitude < 400.0f) 
    {
        if (Variables.Flags.Accelerometer == true) 
        {
            AB_Attitude_State_Update_Accel(Variables.AttState, Variables.Sensors, Variables.AB_Att_UP_Accel, Variables.AB_Att_Pred, Variables.highG);
        }
    }

    else 
    {
        if (Variables.Flags.Accelerometer == true) 
        {
            if (Variables.Sensors.Accelerometer.norm() > 8.0f && Variables.Sensors.Accelerometer.norm() < 11.0f && Variables.Sensors.Accelerometer.z() < 1.01f*9.802f) 
            {
                if (Variables.VertState.Velocity_Up > 0.3f) 
                {
                    if (Variables.highG == true) 
                    {
                        AB_Attitude_State_Update_Accel(Variables.AttState, Variables.Sensors, Variables.AB_Att_UP_Accel, Variables.AB_Att_Pred, Variables.highG);
                    }
                }
            }
        }
    }

    if (Variables.Flags.GPS == true) 
    {
        if (Variables.Sensors.GPS.block<3, 1>(3, 0).norm() > 20.0f) 
        {
            //AB_Attitude_State_Update_GPS(Variables.AttState, Variables.Sensors, Variables.AB_Att_UP_GPS, Variables.AB_Att_Pred);
        }
    }

    if (Variables.Flags.Magnetometer == true) 
    {
        if (Variables.mag_calibrated == false) 
        {
            Variables.mag_calibration_sum += Variables.Sensors.Magnetometer;
            Variables.mag_calibration_count++;

            if (Variables.mag_calibration_count >= 10) 
            {
                Variables.Sensors.Mag_Reference = Variables.mag_calibration_sum / Variables.mag_calibration_count;
                Variables.Sensors.Mag_Reference.normalize();
                Variables.mag_calibrated = true;
            }
        }

        else 
        {
            if (Variables.burning == false) 
            {
                //AB_Attitude_State_Update_Mag(Variables.AttState, Variables.Sensors, Variables.AB_Att_UP_Mag, Variables.AB_Att_Pred);
            }
        }
    }

    // Inside AB_loop()
    if (Variables.burnout == true && Variables.apogee == false && Variables.VertState.Velocity_Up > 15.0f) 
    {
        // Pass the state, sensors, vertical data, and prediction variables
        //AB_Attitude_Update_PseudoDrag(Variables.AttState, Variables.Sensors, Variables.VertState, Variables.HorizState, Variables.AB_Att_UP_Drag, Variables.AB_Att_Pred);
    }

    //transform the acceleration vector to ENU frame and prepare it for vert and horizontal filter
    snsr_Accel_Rotation(Variables.AttState, Variables.Sensors, Variables.highG);

    //Next its vertical filter
    if (Variables.highG == true) 
    {
        if (Variables.Flags.AccelerometerHG == true) 
        {
            AB_Vertical_State_Prediction(Variables.VertState, Variables.Sensors, Variables.AB_Vert_Pred, Variables.highG);
        }
    }
    else 
    {
        if (Variables.Flags.Accelerometer == true) 
        {
            AB_Vertical_State_Prediction(Variables.VertState, Variables.Sensors, Variables.AB_Vert_Pred, Variables.highG);
        }
    }

    if (Variables.Flags.Barometer == true) 
    {
        AB_Vertical_State_Update_Baro(Variables.VertState, Variables.Sensors, Variables.AB_Vert_UP_Baro, Variables.AB_Vert_Pred);
        
    }

    if (Variables.Flags.GPS == true) 
    {
        //AB_Vertical_State_Update_GPS(Variables.VertState, Variables.Sensors, Variables.AB_Vert_UP_GPS, Variables.AB_Vert_Pred);
    }

    if (abs(Variables.VertState.Velocity_Up) < 0.2) 
    {
        Variables.HorizState.Velocity_North = 0.0f;
        Variables.HorizState.Velocity_East = 0.0f;
    }

    if (Variables.apogee == true) 
    {
        if (Variables.VertState.Altitude < 1.0f) 
        {
            Variables.VertState.Velocity_Up = 0.0f;
        }
    }

    if (Variables.Flags.GPS == false && abs(Variables.VertState.Velocity_Up) > 10.0f) 
    {
        Estimate_Horizontal_Velocity(Variables.AttState, Variables.VertState, Variables.HorizState, Variables.velN, Variables.velE);
        Variables.residN = Variables.HorizState.Velocity_North - Variables.velN;
        Variables.residE = Variables.HorizState.Velocity_East - Variables.velE;

        if (Variables.apogee == false) 
        {
            Variables.alpha = 0.0008f;
        }

        else 
        {
            Variables.alpha = 0.002f;
        }
        
        if (abs(Variables.residN) > 5.0f) 
        {
            Variables.HorizState.Velocity_North = (1 - Variables.alpha)*Variables.HorizState.Velocity_North + Variables.alpha * Variables.velN;
        }

        if (abs(Variables.residE) > 5.0f) 
        {
            Variables.HorizState.Velocity_East = (1 - Variables.alpha)*Variables.HorizState.Velocity_East + Variables.alpha * Variables.velE;
        }
    }

    //finally the horizontal filter.
    if (Variables.highG == true) 
    {
        if (Variables.Flags.AccelerometerHG == true) 
        {
            AB_Horizontal_State_Prediction(Variables.HorizState, Variables.Sensors, Variables.AB_Horiz_Pred, Variables.highG);
        }
    }

    else 
    {
        if (Variables.Flags.Accelerometer == true) 
        {
            AB_Horizontal_State_Prediction(Variables.HorizState, Variables.Sensors, Variables.AB_Horiz_Pred, Variables.highG);
            
        }
    }

    if (Variables.Flags.GPS == true) 
    {
        //AB_Horizontal_State_Update_GPS(Variables.HorizState, Variables.Sensors, Variables.AB_Horiz_UP_GPS, Variables.AB_Horiz_Pred);
        
    }

    Variables.Flags.Gyroscope = false;
    Variables.Flags.Accelerometer = false;
    Variables.Flags.AccelerometerHG = false;
    Variables.Flags.GPS = false;
    Variables.Flags.Magnetometer = false;
    Variables.Flags.Barometer = false;

    //Here we save old sensor data
    Variables.PrevSensors.Accelerometer = Variables.Sensors.Accelerometer;
    Variables.PrevSensors.AccelerometerHG = Variables.Sensors.AccelerometerHG;
    Variables.PrevSensors.Gyroscope = Variables.Sensors.Gyroscope;
    Variables.PrevSensors.Magnetometer = Variables.Sensors.Magnetometer;
    Variables.PrevSensors.GPS = Variables.Sensors.GPS;
    Variables.PrevSensors.Barometer = Variables.Sensors.Barometer;
}


