#include "AB_Attitude_Filter.h"

// Initializes and fills in the attitude state and neccessary variables for future calculations
void AB_Attitude_State_Initialization(
    AB_Attitude_State &sN,
    AB_Attitude_Prediction &PredVars)
{
    sN.Quaternion_Body_To_ENU.setIdentity(); // TODO - replace with mag reading
    sN.Gyro_Bias(0, 0) = 0.0f;
    sN.Gyro_Bias(1, 0) = 0.0f;
    sN.Gyro_Bias(2, 0) = 0.0f;
    sN.Accel_Bias(0, 0) = 0.0f;
    sN.Accel_Bias(1, 0) = 0.0f;
    sN.Accel_Bias(2, 0) = 0.0f;

    // Fairly confident in integration for position, biases are really low
    PredVars.C.setIdentity();
    PredVars.Q.setZero();
    PredVars.Q(0, 0) = 5e-4f;
    PredVars.Q(1, 1) = 5e-4f;
    PredVars.Q(2, 2) = 5e-4f;
    PredVars.Q(3, 3) = 5e-7f;
    PredVars.Q(4, 4) = 5e-7f;
    PredVars.Q(5, 5) = 5e-7f;
    PredVars.Q(6, 6) = 0.0f;
    PredVars.Q(7, 7) = 0.0f;
    PredVars.Q(8, 8) = 0.0f;
}

// Takes the calculation variables, current state, and new gyroscope data from the sensor struct and
// computes the prediction step
void AB_Attitude_State_Prediction(
    AB_Attitude_State &sN,
    const AB_Filter_Inputs &inputs,
    AB_Attitude_Prediction &Variables)
{
    float gyroX = inputs.Gyroscope_radps(0); // grabbing angular velocity about the x axis from sensor struct
    float gyroY = inputs.Gyroscope_radps(1); // grabbing angular velocity about the y axis from sensor struct
    float gyroZ = inputs.Gyroscope_radps(2); // grabbing angular velocity about the z axis from sensor struct

    float angX = gyroX - sN.Gyro_Bias(0, 0); // true angular velocity about x axis
    float angY = gyroY - sN.Gyro_Bias(1, 0); // true angular velocity about y axis
    float angZ = gyroZ - sN.Gyro_Bias(2, 0); // true angular velocity about z axis

    // build deltaQuat (exact rotation, not first-order approximation)
    Quaternionf quatDelt;
    float omegaNorm = sqrtf(angX*angX + angY*angY + angZ*angZ);
    if (omegaNorm > 1e-6f) {
        float halfAngle = 0.5f * omegaNorm * inputs.dt;
        float s = sinf(halfAngle) / omegaNorm;
        quatDelt.w() = cosf(halfAngle);
        quatDelt.x() = s * angX;
        quatDelt.y() = s * angY;
        quatDelt.z() = s * angZ;
    } else {
        quatDelt.w() = 1.0f;
        quatDelt.x() = 0.5f * angX * inputs.dt;
        quatDelt.y() = 0.5f * angY * inputs.dt;
        quatDelt.z() = 0.5f * angZ * inputs.dt;
    }

    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * quatDelt; // update quaternionBody->ENU
    sN.Quaternion_Body_To_ENU.normalize();                            // normalize after every integration

    Matrix3f W;
    W << 0.0f, -angZ, angY, angZ, 0.0f, -angX, -angY, angX, 0.0f;

    // jacobian is identity, except middle top 3x3 block is -1*dt
    Matrix<float, 9, 9> F;
    F.setIdentity();
    F.block<3, 3>(0, 0) -= W * inputs.dt;
    F(0, 3) = -1.0f * inputs.dt;
    F(1, 4) = -1.0f * inputs.dt;
    F(2, 5) = -1.0f * inputs.dt;
    Variables.C = F * Variables.C * F.transpose() + Variables.Q; // updating covariance
}

// Takes the calculation variables, current state, and new accelerometer data from the sensor struct and computes
// the update step
void AB_Attitude_State_Update_Accel(
    AB_Attitude_State &sN,
    const AB_Filter_Inputs &sensor,
    AB_Attitude_Prediction &UpVariables,
    const bool HG)
{
    Vector3f accelMeas;
    Matrix<float, 3, 3> R;
    R.setIdentity();

    if (HG == true)
    {
        accelMeas = sensor.AccelerometerHG_mps2; // grabbing vector from sensor struct
        R(0, 0) = 5.0f;
        R(1, 1) = 5.0f;
        R(2, 2) = 5.0f;
    }
    else
    {
        accelMeas = sensor.Accelerometer_mps2; // grabbing vector from sensor struct
        R(0, 0) = 0.05f;
        R(1, 1) = 0.05f;
        R(2, 2) = 0.05f;
    }
    const Vector3f grav(0.0f, 0.0f, 1.0f);
    accelMeas.normalize();                                        // normalize it for saftey
    Vector3f accelPred = sN.Quaternion_Body_To_ENU.conjugate() * grav; // rotate gravity vector to body
    Vector3f y = accelMeas - accelPred;                           // residual
    Matrix3f a_skew;
    a_skew << 0.0f, -1.0f * accelPred.z(), accelPred.y(),
        accelPred.z(), 0.0f, -1.0f * accelPred.x(),
        -1.0f * accelPred.y(), accelPred.x(), 0.0f;

    // measurement jacobian is pretty simple, top left block is that DCM, and botom right(accel bias) is identity
    Matrix<float, 3, 9> H;
    H.setZero();
    H.block<3, 3>(0, 0) = a_skew;
    H.block<3, 3>(0, 6).setIdentity();

    // Now we find the kalman gain, K
    Matrix<float, 9, 3> K = UpVariables.C * H.transpose() * (H * UpVariables.C * H.transpose() + R).inverse();

    // We also find the error state
    Matrix<float, 9, 1> sE = K * y;

    // we add those corrections to the nominal state
    sN.Gyro_Bias(0) += sE(3);
    sN.Gyro_Bias(1) += sE(4);
    sN.Gyro_Bias(2) += sE(5);
    sN.Accel_Bias(0) += sE(6);
    sN.Accel_Bias(1) += sE(7);
    sN.Accel_Bias(2) += sE(8);

    // here we are updating the state quaternion using the error state
    Vector3f thetaError;
    thetaError << sE(0), sE(1), sE(2); // error in angle
    Quaternionf qCorrection;
    qCorrection.w() = 1.0f;
    qCorrection.x() = 0.5f * thetaError.x();
    qCorrection.y() = 0.5f * thetaError.y();
    qCorrection.z() = 0.5f * thetaError.z();                    // correction using that angle
    qCorrection.normalize();                                     // normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * qCorrection; // update using multiplication
    sN.Quaternion_Body_To_ENU.normalize();                       // another saftey normalization

    // finally, we update the covariance
    Matrix<float, 9, 9> I;
    I.setIdentity();
    UpVariables.C = (I - K * H) * UpVariables.C;
}

// Takes the calculation variables, current state, and new gps data from the sensor struct and computes
// the update step
void AB_Attitude_State_Update_GPS(
    AB_Attitude_State &sN,
    const AB_Filter_Inputs &sensor,
    AB_Attitude_Prediction &UpVariables)
{
    const Vector3f noseVec(0.0f, 0.0f, 1.0f);
    Matrix<float, 3, 3> R;
    R.setIdentity();
    R(0, 0) = 0.5f;
    R(1, 1) = 0.5f;
    R(2, 2) = 0.5f;

    Vector3f GPSMeas = sensor.GPS_Velocity_mps;
    GPSMeas.normalize();                                     // normalize it for saftey
    Vector3f GPSPred = sN.Quaternion_Body_To_ENU.conjugate() * GPSMeas; // rotate velocity vector to body
    Vector3f y = noseVec - GPSPred;                          // residual
    Matrix3f a_skew;
    a_skew << 0.0f, -1.0f * GPSPred.z(), GPSPred.y(),
        GPSPred.z(), 0.0f, -1.0f * GPSPred.x(),
        -1.0f * GPSPred.y(), GPSPred.x(), 0.0f;

    // measurement jacobian is pretty simple, top left block is that DCM, and botom right(accel bias) is identity
    Matrix<float, 3, 9> H;
    H.setZero();
    H.block<3, 3>(0, 0) = a_skew;

    // Now we find the kalman gain, K
    Matrix<float, 9, 3> K = UpVariables.C * H.transpose() * (H * UpVariables.C * H.transpose() + R).inverse();

    // We also find the error state
    Matrix<float, 9, 1> sE = K * y;

    // we add those corrections to the nominal state
    sN.Gyro_Bias(0) += sE(3);
    sN.Gyro_Bias(1) += sE(4);
    sN.Gyro_Bias(2) += sE(5);

    // here we are updating the state quaternion using the error state
    Vector3f thetaError;
    thetaError << sE(0), sE(1), sE(2); // error in angle
    Quaternionf qCorrection;
    qCorrection.w() = 1.0f;
    qCorrection.x() = 0.5f * thetaError.x();
    qCorrection.y() = 0.5f * thetaError.y();
    qCorrection.z() = 0.5f * thetaError.z();                    // correction using that angle
    qCorrection.normalize();                                     // normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * qCorrection; // update using multiplication
    sN.Quaternion_Body_To_ENU.normalize();                       // another saftey normalization

    // finally, we update the covariance
    Matrix<float, 9, 9> I;
    I.setIdentity();
    UpVariables.C = (I - K * H) * UpVariables.C;
}

// Takes the calculation variables, current state, and new magnometer data from the sensor struct and computes
// the update step
void AB_Attitude_State_Update_Mag(
    AB_Attitude_State &sN,
    const AB_Filter_Inputs &sensor,
    AB_Attitude_Prediction &UpVariables)
{
    // TODO: i deleted some stuff to make it compile, what did this break?
    Matrix<float, 3, 3> R;
    R.setIdentity();
    R(0, 0) = 0.01108809f;
    R(1, 1) = 0.01435204f;
    R(2, 2) = 0.01468944f;

    Matrix3f a_skew;
    a_skew.setZero();
    Vector3f y;
    y.setZero();

    // measurement jacobian is pretty simple, top left block is that DCM, and botom right(accel bias) is identity
    Matrix<float, 3, 9> H;
    H.setZero();
    H.block<3, 3>(0, 0) = a_skew;

    // Now we find the kalman gain, K
    Matrix<float, 9, 3> K = UpVariables.C * H.transpose() * (H * UpVariables.C * H.transpose() + R).inverse();

    // We also find the error state
    Matrix<float, 9, 1> sE = K * y;

    // we add those corrections to the nominal state
    sN.Gyro_Bias(0) += sE(3);
    sN.Gyro_Bias(1) += sE(4);
    sN.Gyro_Bias(2) += sE(5);

    // here we are updating the state quaternion using the error state
    Vector3f thetaError;
    thetaError << sE(0), sE(1), sE(2); // error in angle
    Quaternionf qCorrection;
    qCorrection.w() = 1.0f;
    qCorrection.x() = 0.5f * thetaError.x();
    qCorrection.y() = 0.5f * thetaError.y();
    qCorrection.z() = 0.5f * thetaError.z();                    // correction using that angle
    qCorrection.normalize();                                     // normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * qCorrection; // update using multiplication
    sN.Quaternion_Body_To_ENU.normalize();                       // another saftey normalization

    // finally, we update the covariance
    Matrix<float, 9, 9> I;
    I.setIdentity();
    UpVariables.C = (I - K * H) * UpVariables.C;
}

// if we are running with gps and are traveling at a fast speed, we can trust the drag that the sensors measure, and velocity estimate and use them to help correct our orientation
void AB_Attitude_Update_PseudoDrag(
    AB_Attitude_State &sN,
    const AB_Filter_Inputs &sensor,
    AB_Vertical_State &vState,
    AB_Horizontal_State &hState,
    AB_Attitude_Prediction &UpVariables)
{
    const float deg10 = 10.0f * (3.14159265358979323846f / 180.0f);
    const float R_lo = 1.0f;
    const float R_hi = 5.0f;

    // if the speed is high, we can trust more.
    float speed = fabs(vState.VelocityUp_mps);
    if (speed < 15.0f)
    {
        return;
    }

    // predict drag from velocity
    Vector3f v_n;
    v_n << hState.VelocityEast_mps, hState.VelocityNorth_mps, vState.VelocityUp_mps; // grabbing velocity
    float vnorm = v_n.norm();
    if (vnorm < 1.0f)
    {
        return;
    }
    Vector3f v_n_hat = v_n / vnorm;
    Vector3f d_n_hat = -1 * v_n_hat; // drag points opposite direction of velocity

    // Rotating to body frame
    Vector3f d_pred_b = sN.Quaternion_Body_To_ENU.conjugate() * d_n_hat;
    d_pred_b.normalize();

    // drag from accelerometer
    Vector3f a_b = sensor.Accelerometer_mps2 * gravity(vState.Altitude_m);

    Vector3f g_n;
    g_n << 0.0f, 0.0f, gravity(vState.Altitude_m); // enu gravity
    Vector3f g_b = sN.Quaternion_Body_To_ENU.conjugate() * g_n;

    Vector3f accel_bias_ms2;
    accel_bias_ms2 << sN.Accel_Bias(0) * gravity(vState.Altitude_m),
        sN.Accel_Bias(1) * gravity(vState.Altitude_m),
        sN.Accel_Bias(2) * gravity(vState.Altitude_m);

    // obtain drag force on body
    Vector3f f_b = a_b - g_b - accel_bias_ms2;
    float fnorm = f_b.norm();

    // if drag is too small, don't use it(.2g rn)
    if (fnorm < 2.0f)
    {
        return;
    }
    Vector3f d_meas_b = f_b / fnorm;

    // only update if the disagreement btw the state and drag is > 10degrees
    float c = d_meas_b.dot(d_pred_b);
    c = std::max(-1.0f, std::min(1.0f, c));
    float angle = std::acos(c);

    if (angle < deg10)
    {
        return;
    }

    Vector3f y = d_meas_b - d_pred_b;

    // H assumes no other influences
    Matrix3f I33;
    I33.setIdentity();
    Matrix3f d_skew;
    d_skew << 0.0f, -d_pred_b.z(), d_pred_b.y(),
        d_pred_b.z(), 0.0f, -d_pred_b.x(),
        -d_pred_b.y(), d_pred_b.x(), 0.0f;

    Matrix<float, 3, 9> H;
    H.setZero();
    H.block<3, 3>(0, 0) = d_skew;
    H.block<3, 3>(0, 6) = -I33;

    // higher R value if the value disagrees heavily.
    float angle_over = std::max(0.0f, angle - deg10);
    float strength = std::min(1.0f, angle_over / (20.0f * 3.14159265f / 180.0f)); // linear ramp
    float Rv = (1.0f - strength) * R_hi + strength * R_lo;

    Matrix<float, 3, 3> R;
    R.setIdentity();
    R *= Rv;
    Matrix<float, 9, 3> K = UpVariables.C * H.transpose() * (H * UpVariables.C * H.transpose() + R).inverse();
    Matrix<float, 9, 1> sE = K * y;
    sN.Gyro_Bias(0) += sE(3);
    sN.Gyro_Bias(1) += sE(4);
    sN.Gyro_Bias(2) += sE(5);
    sN.Accel_Bias(0) += sE(6);
    sN.Accel_Bias(1) += sE(7);
    sN.Accel_Bias(2) += sE(8);

    // Quaternion correction
    Vector3f thetaError;
    thetaError << sE(0), sE(1), sE(2); // error in angle
    Quaternionf qCorrection;
    qCorrection.w() = 1.0f;
    qCorrection.x() = 0.5f * thetaError.x();
    qCorrection.y() = 0.5f * thetaError.y();
    qCorrection.z() = 0.5f * thetaError.z();                    // correction using that angle
    qCorrection.normalize();                                     // normalize for saftey
    sN.Quaternion_Body_To_ENU = sN.Quaternion_Body_To_ENU * qCorrection; // update using multiplication
    sN.Quaternion_Body_To_ENU.normalize();                       // another saftey normalization

    // update covariance
    Matrix<float, 9, 9> I;
    I.setIdentity();
    UpVariables.C = (I - K * H) * UpVariables.C;
}
