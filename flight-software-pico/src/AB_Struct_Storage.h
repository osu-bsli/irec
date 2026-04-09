#pragma once

#include "Eigen/Dense"
using namespace Eigen;
//Input Variables come from struct. The purpose of this file is to remove all dynamic and on the fly initialized
//variables from the code, so can properly keep track of the maximum allowed memory use.

struct AB_Snsrs { //Struct containing all sensor data
    Matrix<float, 3, 1>Accelerometer; //Accel(m/s^2) X, Y, Z
    Matrix<float, 3, 1>AccelerometerHG; //Accel(m/s^2) X, Y, Z
    Matrix<float, 3, 1>AccelerometerWorld; //Accel(m/s^2) X, Y, Z
    Matrix<float, 3, 1> Gyroscope; //AngularV(rad/s) X, Y, Z
    Matrix<float, 3, 1> Magnetometer; //Field(uT) X, Y, Z
    Matrix<float, 6, 1> GPS; //position(m) X, Y, Z and velocity(m/s) X, Y, Z
    float Barometer; //altitude(m) Z
    float dt; //time between last sensor change, needs to be updated every time.
    Vector3f Mag_Reference;
};

struct AB_Snsrs_prevData { //Struct containing all sensor data
    Matrix<float, 3, 1>Accelerometer; //Accel(m/s^2) X, Y, Z
    Matrix<float, 3, 1>AccelerometerHG; //Accel(m/s^2) X, Y, Z
    Matrix<float, 3, 1> Gyroscope; //AngularV(rad/s) X, Y, Z
    Matrix<float, 3, 1> Magnetometer; //Field(uT) X, Y, Z
    Matrix<float, 6, 1> GPS; //position(m) X, Y, Z and velocity(m/s) X, Y, Z
    float Barometer; //altitude(m) Z
};

struct AB_Snsrs_booleans { //Struct containing all sensor data
    bool Accelerometer; //Accel(m/s^2) X, Y, Z
    bool AccelerometerHG; //Accel(m/s^2) X, Y, Z
    bool Gyroscope; //AngularV(rad/s) X, Y, Z
    bool Magnetometer; //Field(uT) X, Y, Z
    bool GPS; //position(m) X, Y, Z and velocity(m/s) X, Y, Z
    bool Barometer; //altitude(m) Z
};

struct AB_Attitude_State { //struct containing the state for the rocket's attitude
    Quaternionf Quaternion_Body_To_ENU; //quaternion describing rotation from body frame to ENU
    Matrix<float, 3, 1> Gyro_Bias; //bias of the gyroscope
    Matrix<float, 3, 1> Accel_Bias; //bias of the accelerometer
};

struct AB_Vertical_State { //struct containing the state for the rocket's vertical motion
    float Altitude; //current height of the rocket relative to starting height
    float Velocity_Up; //current velocity of the rocket relative to starting velocity
    float Baro_Bias; //barometer bias 
};

struct AB_Horizontal_State { //struct containing the state for the rocket's horizontal motion
    float Position_East; //position in East direction relative to starting position
    float Position_North; //position in North direction relative to starting position
    float Velocity_East; //Velocity in East direction relative to starting position
    float Velocity_North; //Velocity in North direction relative to starting position
};

struct AB_Attitude_Prediction{//prediction variables(uses gyro XYZ)
    Matrix<float, 9, 9> F;
    Matrix<float, 9, 9> C;
    Matrix<float, 9, 9> Q; 
    float dt;
    float GyroX;
    float GyroY;
    float GyroZ;
    float angX;
    float angY;
    float angZ;
    Quaternionf quatDelt;
    Matrix3f W;
};

struct AB_Attitude_Update_Accel{//update using accel variables(uses accel XYZ)
    Matrix<float, 3, 1> d;
    Matrix<float, 3, 1> y;
    Matrix<float, 3, 9> H;
    Matrix<float, 9, 3> K;
    Matrix<float, 3, 3> R;
    Matrix<float, 9, 1> sE;  
    Vector3f accelMeas;
    Matrix<float, 9, 9> I;
    Vector3f grav;
    Vector3f accelPred;
    Matrix3f a_skew;
    Vector3f thetaError;
    Quaternionf qCorrection;
};

struct AB_Attitude_Update_GPS{//update using gps variables(uses gps velocity XYZ)
    Matrix<float, 3, 1> d;
    Matrix<float, 3, 1> y;
    Matrix<float, 3, 9> H;
    Matrix<float, 9, 3> K;
    Matrix<float, 3, 3> R;
    Matrix<float, 9, 1> sE;  
    Matrix<float, 9, 9> I;
    Vector3f GPSMeas;
    Vector3f GPSPred;
    Vector3f noseVec;
    Matrix3f a_skew;
    Vector3f thetaError;
    Quaternionf qCorrection;
};

struct AB_Attitude_Update_Mag{//update using magnometer variables(uses magnometer XYZ)
    Matrix<float, 3, 1> d;
    Matrix<float, 3, 1> y;
    Matrix<float, 3, 9> H;
    Matrix<float, 9, 3> K;
    Matrix<float, 3, 3> R;
    Matrix<float, 9, 1> sE; 
    Matrix<float, 9, 9> I;
    Vector3f MagMeas;
    Vector3f MagPred;
    Matrix3f a_skew;
    Vector3f thetaError;
    Quaternionf qCorrection;
}; 

struct AB_Attitude_Update_Drag{//update using drag velocity
    Matrix<float, 3, 1> y;
    Matrix<float, 3, 9> H;
    Matrix<float, 9, 3> K;
    Matrix<float, 3, 3> R;
    Matrix<float, 9, 1> sE;  
    Matrix<float, 9, 9> I;
    Matrix<float, 3, 3> I33;
    float deg10;
    float speed;
    Vector3f v_n;
    float vnorm;
    Vector3f v_n_hat;
    Vector3f d_n_hat;
    Vector3f d_pred_b;
    Vector3f a_b;
    Vector3f g_n;
    Vector3f g_b;
    Vector3f accel_bias_ms2;
    Vector3f f_b;
    float fnorm;
    Vector3f d_meas_b;
    float c;
    float angle;
    Matrix3f d_skew;
    float angle_over;
    float strength;
    float R_lo;
    float R_hi;
    float Rv;
    Vector3f thetaError;
    Quaternionf qCorrection;
}; 

struct AB_Vertical_Prediction{//prediction variables(uses accel Z)
    Matrix<float, 3, 3> F;
    Matrix<float, 3, 3> C;
    Matrix<float, 3, 3> Q;
    float dt;
    float AccelZ;
    float AccelUp;
    float oldVel;
};

struct AB_Vertical_Update_Baro{//update using baro struct(uses baro altitude)
    Matrix<float, 1, 1> d;
    Matrix<float, 1, 1> y;
    Matrix<float, 1, 3> H;
    Matrix<float, 3, 1> K;
    Matrix<float, 1, 1> R;
    Matrix<float, 3, 1> sE;   
    Matrix<float, 3, 3> I;
}; 

struct AB_Vertical_Update_GPS{//update using gps struct(uses gps altitude)
    Matrix<float, 2, 1> d;
    Matrix<float, 2, 1> y;
    Matrix<float, 2, 3> H;
    Matrix<float, 3, 2> K;
    Matrix<float, 2, 2> R;
    Matrix<float, 3, 1> sE;
    Matrix<float, 3, 3> I;
}; 

struct AB_Horizontal_Prediction{//prediction variables(uses accel XYZ)
    Matrix<float, 4, 4> F;
    Matrix<float, 4, 4> C;
    Matrix<float, 4, 4> Q;
    float dt;
    float AccelE;
    float AccelN;
    float oldEVel;
    float oldNVel;
};

struct AB_Horizontal_Update_GPS{//update using gps struct(uses gps position and velocity in N and E)
    Matrix<float, 4, 1> d;
    Matrix<float, 4, 1> y;
    Matrix<float, 4, 4> H;
    Matrix<float, 4, 4> K;
    Matrix<float, 4, 4> R;
    Matrix<float, 4, 1> sE;
    Matrix<float, 4, 4> I;
}; 

struct AB_Predict_Deployment_Angle_Variables{//runtime variables for angle deployment function
    float low;
    float high;
    float mid;
    float targetApogee;
    float currentAlt;
    float currentTarget;
    float predictedApogee;
};

struct AB_Predict_Apogee_Variables{//runtime variables for apogee prediction function
    float positionZ; 
    float velocityZ;
    float thetaZ; 
    float deploymentAngle;
    float dt;
    int iter;
    float cos_theta;
    float v_total1;
    float k1_rho;
    float drag1;
    float k1_v;
    float k1_x;
    float k1_theta;
    float vk1;
    float posk1;
    float thetaK1;
    float cos_tk1;
    float v_total2;
    float k2_rho;
    float drag2;
    float k2_v;
    float k2_x;
    float k2_theta;
    float vk2;
    float posk2;
    float thetaK2;
    float cos_tk2;
    float v_total3;
    float k3_rho;
    float drag3;
    float k3_v;
    float k3_x;
    float k3_theta;
    float vk3;
    float posk3;
    float thetaK3;
    float cos_tk3;
    float v_total4;
    float k4_rho;
    float drag4;
    float k4_v;
    float k4_x;
    float k4_theta;
};

struct AB_Filter_Main_Variables{
    // structs for states and inputs
    AB_Snsrs Sensors;
    AB_Snsrs_prevData PrevSensors;
    AB_Snsrs_booleans Flags;
    AB_Vertical_State VertState;
    AB_Horizontal_State HorizState;
    AB_Attitude_State AttState;

    // filter variables
    AB_Attitude_Prediction AB_Att_Pred;
    AB_Attitude_Update_Accel AB_Att_UP_Accel;
    AB_Attitude_Update_GPS AB_Att_UP_GPS;
    AB_Attitude_Update_Mag AB_Att_UP_Mag;
    AB_Attitude_Update_Drag AB_Att_UP_Drag;
    AB_Vertical_Prediction AB_Vert_Pred;
    AB_Vertical_Update_Baro AB_Vert_UP_Baro;
    AB_Vertical_Update_GPS AB_Vert_UP_GPS;
    AB_Horizontal_Prediction AB_Horiz_Pred;
    AB_Horizontal_Update_GPS AB_Horiz_UP_GPS;

    // variables for runtime
    bool highG;
    float max_apogee;
    bool apogee;
    bool burning;
    bool burnout;
    float time_since_launch;
    int mag_calibration_count;
    bool mag_calibrated;
    float accel_z_current;
    float velN;
    float velE;
    float alpha;
    float residN;
    float residE;

    // vectors for runtime
    Eigen::Vector3f R0;
    Eigen::Vector3f Rdot;
    Eigen::Vector3f R;
    Eigen::Vector3f AccelBias;
    Eigen::Vector3f Mag_Reference;
    Eigen::Vector3f mag_calibration_sum;
};
