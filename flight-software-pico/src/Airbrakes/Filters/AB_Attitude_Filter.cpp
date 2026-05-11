#include "AB_Attitude_Filter.h"

//Initializes and fills in the attitude state and neccessary variables for future calculations
void AB_Attitude_State_Initialization (
    AB_Attitude_State& sN, 
    AB_Attitude_Prediction& PredVars,
    AB_Attitude_Update_Accel& AccelVars,
    AB_Attitude_Update_GPS& GPSVars,
    AB_Attitude_Update_Mag& MagVars,
    AB_Attitude_Update_Drag& DragVars 
) 
{
    sN.Quaternion_Body_To_ENU.setIdentity(); //TODO - replace with mag reading
    sN.Gyro_Bias(0, 0) = 0.0f; 
    sN.Gyro_Bias(1, 0) = 0.0f; 
    sN.Gyro_Bias(2, 0) = 0.0f; 
    sN.Accel_Bias(0, 0) = 0.0f; 
    sN.Accel_Bias(1, 0) = 0.0f; 
    sN.Accel_Bias(2, 0) = 0.0f; 

    //Fairly confident in integration for position, biases are really low
    PredVars.F.setIdentity();
    PredVars.C.setIdentity();
    PredVars.Q.setZero();
    PredVars.Q(0, 0) = 5e-4f;
    PredVars.Q(1, 1) = 5e-4f;
    PredVars.Q(2, 2) =  5e-4f;
    PredVars.Q(3, 3) = 5e-7f;
    PredVars.Q(4, 4) = 5e-7f;
    PredVars.Q(5, 5) = 5e-7f;
    PredVars.Q(6, 6) = 0.0f;
    PredVars.Q(7, 7) = 0.0f;
    PredVars.Q(8, 8) = 0.0f;

    //Everthing to zero except for the accel, which we trust heavily
    AccelVars.d.setZero();
    AccelVars.y.setZero();
    AccelVars.H.setZero();
    AccelVars.K.setZero();
    AccelVars.R.setIdentity();
    AccelVars.R(0, 0) = .05f;
    AccelVars.R(1, 1) = .05f;
    AccelVars.R(2, 2) = .05f;
    AccelVars.sE.setZero();
    AccelVars.I.setIdentity();
    AccelVars.grav << 0.0f, 0.0f, 1.0f;

    //Everthing to zero except for the gps, for velocity we trust a lot
    GPSVars.d.setZero();
    GPSVars.y.setZero();
    GPSVars.H.setZero();
    GPSVars.K.setZero();
    GPSVars.R.setIdentity();
    GPSVars.R(0, 0) = 0.5f;
    GPSVars.R(1, 1) = 0.5f;
    GPSVars.R(2, 2) = 0.5f;
    GPSVars.sE.setZero();
    GPSVars.I.setIdentity();
    GPSVars.noseVec << 0.0f, 0.0f, 1.0f;

    //Everthing to zero except for the mag, which we dont trust too much
    MagVars.d.setZero();
    MagVars.y.setZero();
    MagVars.H.setZero();
    MagVars.K.setZero();
    MagVars.R.setIdentity();
    MagVars.R(0, 0) = 0.01108809f;
    MagVars.R(1, 1) = 0.01435204f;
    MagVars.R(2, 2) = 0.01468944f;
    MagVars.sE.setZero();
    MagVars.I.setIdentity();

    DragVars.y.setZero();
    DragVars.H.setZero();
    DragVars.K.setZero();
    DragVars.R.setIdentity();
    DragVars.sE.setZero();
    DragVars.I.setIdentity();
    DragVars.deg10 = 10.0f * (3.14159265358979323846f / 180.0f);
    DragVars.R_lo = 1.0f;
    DragVars.R_hi = 5.0f;
    DragVars.I33.setIdentity();
}

//Takes the calculation variables, current state, and new gyroscope data from the sensor struct and 
//computes the prediction step
void AB_Attitude_State_Prediction (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Prediction& Variables
) 
{
    Variables.dt = sensor.dt; //grabbing deltaT from the sensor struct.
    Variables.GyroX = sensor.Gyroscope(0); //grabbing angular velocity about the x axis from sensor struct
    Variables.GyroY = sensor.Gyroscope(1); //grabbing angular velocity about the y axis from sensor struct
    Variables.GyroZ = sensor.Gyroscope(2); //grabbing angular velocity about the z axis from sensor struct

    Variables.angX = Variables.GyroX - sN.Gyro_Bias(0, 0); //true angular velocity about x axis
    Variables.angY = Variables.GyroY - sN.Gyro_Bias(1, 0); //true angular velocity about y axis
    Variables.angZ = Variables.GyroZ - sN.Gyro_Bias(2, 0); //true angular velocity about z axis

    //build deltaQuat
    Variables.quatDelt.w() = 1.0f;
    Variables.quatDelt.x() = 0.5 * Variables.angX * Variables.dt;
    Variables.quatDelt.y() = 0.5 * Variables.angY * Variables.dt;
    Variables.quatDelt.z() = 0.5 * Variables.angZ * Variables.dt; 
    
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * Variables.quatDelt; //update quaternionBody->ENU
    sN.Quaternion_Body_To_ENU.normalize(); //normalize after every integration

    Variables.W << 0.0f,   -Variables.angZ,   Variables.angY, Variables.angZ,   0.0f,   -Variables.angX, -Variables.angY,    Variables.angX,  0.0f;

    //jacobian is identity, except middle top 3x3 block is -1*dt
    Variables.F.setIdentity();
    Variables.F.block<3,3>(0,0) -= Variables.W * Variables.dt;    
    Variables.F(0, 3) = -1.0f * Variables.dt; 
    Variables.F(1, 4) = -1.0f * Variables.dt; 
    Variables.F(2, 5) = -1.0f * Variables.dt; 
    Variables.C = Variables.F * Variables.C * Variables.F.transpose() + Variables.Q; //updating covariance
}

//Takes the calculation variables, current state, and new accelerometer data from the sensor struct and computes 
//the update step
void AB_Attitude_State_Update_Accel (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Update_Accel& Variables,
    AB_Attitude_Prediction& UpVariables,
    const bool HG
) {

    if (HG == true) {
        Variables.accelMeas = sensor.AccelerometerHG; //grabbing vector from sensor struct
        Variables.R(0, 0) = 5.0f;
        Variables.R(1, 1) = 5.0f;
        Variables.R(2, 2) = 5.0f;
    }
    else {
        Variables.accelMeas = sensor.Accelerometer; //grabbing vector from sensor struct
        Variables.R(0, 0) = 0.05f;
        Variables.R(1, 1) = 0.05f;
        Variables.R(2, 2) = 0.05f;
    }
    Variables.accelMeas.normalize(); //normalize it for saftey
    Variables.accelPred = sN.Quaternion_Body_To_ENU.conjugate() * Variables.grav; //rotate gravity vector to body
    Variables.y = Variables.accelMeas - Variables.accelPred; //residual
    Variables.a_skew << 0.0f, -1.0f * Variables.accelPred.z(), Variables.accelPred.y(), 
    Variables.accelPred.z(), 0.0f, -1.0f * Variables.accelPred.x(), 
    -1.0f * Variables.accelPred.y(), Variables.accelPred.x(), 0.0f;
    
    //measurement jacobian is pretty simple, top left block is that DCM, and botom right(accel bias) is identity
    Variables.H.setZero();
    Variables.H.block<3, 3>(0, 0) = Variables.a_skew;
    Variables.H.block<3, 3>(0, 6).setIdentity();

    //Now we find the kalman gain, K
    Variables.K = UpVariables.C * Variables.H.transpose() * (Variables.H * UpVariables.C * Variables.H.transpose() + Variables.R).inverse();

    //We also find the error state
    Variables.sE = Variables.K * Variables.y;

    //we add those corrections to the nominal state
    sN.Gyro_Bias(0) += Variables.sE(3);
    sN.Gyro_Bias(1) += Variables.sE(4);
    sN.Gyro_Bias(2) += Variables.sE(5);
    sN.Accel_Bias(0) += Variables.sE(6);
    sN.Accel_Bias(1) += Variables.sE(7);
    sN.Accel_Bias(2) += Variables.sE(8);

    //here we are updating the state quaternion using the error state 
    Variables.thetaError << Variables.sE(0), Variables.sE(1), Variables.sE(2); //error in angle
    Variables.qCorrection.w() = 1.0f;
    Variables.qCorrection.x() = 0.5f * Variables.thetaError.x();
    Variables.qCorrection.y() = 0.5f * Variables.thetaError.y();
    Variables.qCorrection.z() = 0.5f * Variables.thetaError.z(); //correction using that angle
    Variables.qCorrection.normalize(); //normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * Variables.qCorrection; //update using multiplication
    sN.Quaternion_Body_To_ENU.normalize(); //another saftey normalization

    //finally, we update the covariance
    UpVariables.C = (Variables.I - Variables.K * Variables.H) * UpVariables.C;
}

//Takes the calculation variables, current state, and new gps data from the sensor struct and computes 
//the update step
void AB_Attitude_State_Update_GPS (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Update_GPS& Variables,
    AB_Attitude_Prediction& UpVariables
) 
{
    Variables.GPSMeas = sensor.GPS.block<3, 1>(3, 0); //grabbing vector from sensor struct
    Variables.GPSMeas.normalize(); //normalize it for saftey
    Variables.GPSPred = sN.Quaternion_Body_To_ENU.conjugate() * Variables.GPSMeas; //rotate velocity vector to body
    Variables.y = Variables.noseVec - Variables.GPSPred; //residual
    Variables.a_skew << 0.0f, -1.0f * Variables.GPSPred.z(), Variables.GPSPred.y(), 
    Variables.GPSPred.z(), 0.0f, -1.0f * Variables.GPSPred.x(), 
    -1.0f * Variables.GPSPred.y(), Variables.GPSPred.x(), 0.0f;
    
    //measurement jacobian is pretty simple, top left block is that DCM, and botom right(accel bias) is identity
    Variables.H.setZero();
    Variables.H.block<3, 3>(0, 0) = Variables.a_skew;

    //Now we find the kalman gain, K
    Variables.K = UpVariables.C * Variables.H.transpose() * (Variables.H * UpVariables.C * Variables.H.transpose() + Variables.R).inverse();

    //We also find the error state
    Variables.sE = Variables.K * Variables.y;

    //we add those corrections to the nominal state
    sN.Gyro_Bias(0) += Variables.sE(3);
    sN.Gyro_Bias(1) += Variables.sE(4);
    sN.Gyro_Bias(2) += Variables.sE(5);

    //here we are updating the state quaternion using the error state 
    Variables.thetaError << Variables.sE(0), Variables.sE(1), Variables.sE(2); //error in angle
    Variables.qCorrection.w() = 1.0f;
    Variables.qCorrection.x() = 0.5f * Variables.thetaError.x();
    Variables.qCorrection.y() =  0.5f * Variables.thetaError.y();
    Variables.qCorrection.z() =  0.5f * Variables.thetaError.z(); //correction using that angle
    Variables.qCorrection.normalize(); //normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * Variables.qCorrection; //update using multiplication
    sN.Quaternion_Body_To_ENU.normalize(); //another saftey normalization
    
    //finally, we update the covariance
    UpVariables.C = (Variables.I - Variables.K * Variables.H) * UpVariables.C;
}

//Takes the calculation variables, current state, and new magnometer data from the sensor struct and computes 
//the update step
void AB_Attitude_State_Update_Mag (
    AB_Attitude_State& sN, 
    const AB_Snsrs& sensor, 
    AB_Attitude_Update_Mag& Variables,
    AB_Attitude_Prediction& UpVariables
) 
{
    //define I for later use
    Variables.MagMeas = sensor.Magnetometer; //grabbing vector from sensor struct
    Variables.MagMeas.normalize(); //normalize it for saftey
    Variables.MagPred = sN.Quaternion_Body_To_ENU.conjugate() * sensor.Mag_Reference; //rotate velocity vector to body
    Variables.y = Variables.MagMeas - Variables.MagPred; //residual
    Variables.a_skew << 0.0f, -1.0f * Variables.MagPred.z(), Variables.MagPred.y(), 
    Variables.MagPred.z(), 0.0f, -1.0f * Variables.MagPred.x(), 
    -1.0f * Variables.MagPred.y(), Variables.MagPred.x(), 0.0f;
    
    //measurement jacobian is pretty simple, top left block is that DCM, and botom right(accel bias) is identity
    Variables.H.setZero();
    Variables.H.block<3, 3>(0, 0) = Variables.a_skew;

    //Now we find the kalman gain, K
    Variables.K = UpVariables.C * Variables.H.transpose() * (Variables.H * UpVariables.C * Variables.H.transpose() + Variables.R).inverse();

    //We also find the error state
    Variables.sE = Variables.K * Variables.y;

    //we add those corrections to the nominal state
    sN.Gyro_Bias(0) += Variables.sE(3);
    sN.Gyro_Bias(1) += Variables.sE(4);
    sN.Gyro_Bias(2) += Variables.sE(5);

    //here we are updating the state quaternion using the error state 
    Variables.thetaError << Variables.sE(0), Variables.sE(1), Variables.sE(2); //error in angle
    Variables.qCorrection.w() = 1.0f;
    Variables.qCorrection.x() = 0.5f * Variables.thetaError.x();
    Variables.qCorrection.y() =  0.5f * Variables.thetaError.y();
    Variables.qCorrection.z() =  0.5f * Variables.thetaError.z(); //correction using that angle
    Variables.qCorrection.normalize(); //normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * Variables.qCorrection; //update using multiplication
    sN.Quaternion_Body_To_ENU.normalize(); //another saftey normalization
    
    //finally, we update the covariance
    UpVariables.C = (Variables.I - Variables.K * Variables.H) * UpVariables.C;
}

//if we are running with gps and are traveling at a fast speed, we can trust the drag that the sensors measure, and velocity estimate and use them to help correct our orientation
void AB_Attitude_Update_PseudoDrag(
    AB_Attitude_State& sN,
    const AB_Snsrs& sensor,
    AB_Vertical_State& vState,
    AB_Horizontal_State& hState,
    AB_Attitude_Update_Drag& Variables,
    AB_Attitude_Prediction& UpVariables
) 
{
    //if the speed is high, we can trust more.
    Variables.speed = fabs(vState.Velocity_Up);
    if (Variables.speed < 15.0f) 
    {
        return;
    }
    
    //predict drag from velocity
    Variables.v_n << hState.Velocity_East, hState.Velocity_North, vState.Velocity_Up; //grabbing velocity
    Variables.vnorm = Variables.v_n.norm();
    if (Variables.vnorm < 1.0f) 
    {
        return;
    }                   
    Variables.v_n_hat = Variables.v_n / Variables.vnorm;
    Variables.d_n_hat = -1 * Variables.v_n_hat; // drag points opposite direction of velocity

    // Rotating to body frame
    Variables.d_pred_b = sN.Quaternion_Body_To_ENU.conjugate() * Variables.d_n_hat;
    Variables.d_pred_b.normalize();

    // drag from accelerometer
    Variables.a_b = sensor.Accelerometer * gravity(vState.Altitude); 

    Variables.g_n << 0.0f, 0.0f, gravity(vState.Altitude); //enu gravity
    Variables.g_b = sN.Quaternion_Body_To_ENU.conjugate() * Variables.g_n;

    Variables.accel_bias_ms2 <<
        sN.Accel_Bias(0) * gravity(vState.Altitude),
        sN.Accel_Bias(1) * gravity(vState.Altitude),
        sN.Accel_Bias(2) * gravity(vState.Altitude);

    // obtain drag force on body
    Variables.f_b = Variables.a_b - Variables.g_b - Variables.accel_bias_ms2;
    Variables.fnorm = Variables.f_b.norm();

    // if drag is too small, don't use it(.2g rn)
    if (Variables.fnorm < 2.0f) 
    {
        return; 
    }
    Variables.d_meas_b = Variables.f_b / Variables.fnorm;

    //only update if the disagreement btw the state and drag is > 10degrees
    Variables.c = Variables.d_meas_b.dot(Variables.d_pred_b);
    Variables.c = std::max(-1.0f, std::min(1.0f, Variables.c));
    Variables.angle = std::acos(Variables.c);

    if (Variables.angle < Variables.deg10) 
    {
        return;
    }
    
    Variables.y = Variables.d_meas_b - Variables.d_pred_b; 

    // H assumes no other influences
    Variables.d_skew << 0.0f, -Variables.d_pred_b.z(), Variables.d_pred_b.y(),
    Variables.d_pred_b.z(), 0.0f, -Variables.d_pred_b.x(),
    -Variables.d_pred_b.y(), Variables.d_pred_b.x(), 0.0f;

    Variables.H.setZero();                    
    Variables.H.block<3,3>(0,0) = Variables.d_skew;
    Variables.H.block<3,3>(0,6) = -Variables.I33;

    // higher R value if the value disagrees heavily.
    Variables.angle_over = std::max(0.0f, Variables.angle - Variables.deg10);
    Variables.strength = std::min(1.0f, Variables.angle_over / (20.0f * 3.14159265f / 180.0f)); // linear ramp
    Variables.Rv = (1.0f - Variables.strength) * Variables.R_hi + Variables.strength * Variables.R_lo;

    Variables.R *= Variables.Rv;     
    Variables.K = UpVariables.C * Variables.H.transpose() * (Variables.H * UpVariables.C * Variables.H.transpose() + Variables.R).inverse();
    Variables.sE = Variables.K * Variables.y;    
    sN.Gyro_Bias(0)  += Variables.sE(3);
    sN.Gyro_Bias(1)  += Variables.sE(4);
    sN.Gyro_Bias(2)  += Variables.sE(5);
    sN.Accel_Bias(0) += Variables.sE(6);
    sN.Accel_Bias(1) += Variables.sE(7);
    sN.Accel_Bias(2) += Variables.sE(8);

    // Quaternion correction
    Variables.thetaError << Variables.sE(0), Variables.sE(1), Variables.sE(2); //error in angle
    Variables.qCorrection.w() = 1.0f;
    Variables.qCorrection.x() = 0.5f * Variables.thetaError.x();
    Variables.qCorrection.y() = 0.5f * Variables.thetaError.y();
    Variables.qCorrection.z() = 0.5f * Variables.thetaError.z(); //correction using that angle
    Variables.qCorrection.normalize(); //normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * Variables.qCorrection; //update using multiplication
    sN.Quaternion_Body_To_ENU.normalize(); //another saftey normalization

    // update covariance
    UpVariables.C = (Variables.I - Variables.K * Variables.H) * UpVariables.C;
}
