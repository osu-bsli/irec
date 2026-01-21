#include "AltimeterFilter.h"
#include <math.h>
#include <eigen3/Eigen/Dense>
#include <iostream>
#include <array>
#include <boost/numeric/odeint.hpp>
#include <boost/array.hpp>


using Eigen::Matrix;
using Eigen::Vector;

const float deltaT = 0.010f;

static float GetAltitude();
static float GetVelocity();
static float GetAcceleration();
static float GetJerk();

// Vectors in Eigen are column vectors
struct AltimeterFilter
{
    Vector<float, STATE_LEN> state;                    // [altitude_m, vel_z, acc_z, jerk_z]
    Matrix<float, STATE_LEN, STATE_LEN> P;             // Noise covariance
    Matrix<float, OBSERVATION_LEN, STATE_LEN> H;       // State to observation mapping
    Matrix<float, STATE_LEN, STATE_LEN> Phi;           // State transition matrix
    Vector<float, STATE_LEN> B;                        // State transition bias
    Matrix<float, STATE_LEN, STATE_LEN> Q_preApogee;   // Process noise covariance
    Matrix<float, STATE_LEN, STATE_LEN> Q_postApogee;  // Process noise covariance
    Matrix<float, OBSERVATION_LEN, OBSERVATION_LEN> R; // Observation noise covariance

    float max_accel;
    int flight_stage;
    float t_apogee;
};

struct AltimeterFilter f;

static void AltimeterFilterPrint()
{
    std::cout << "\nstate:\n"
              << f.state << std::endl;
    std::cout << "\nP:\n"
              << f.P << std::endl;
    std::cout << "\nH:\n"
              << f.H << std::endl;
    std::cout << "\nPhi:\n"
              << f.Phi << std::endl;
    std::cout << "\nB:\n"
              << f.B << std::endl;
    std::cout << "\nQ_preApogee:\n"
              << f.Q_preApogee << std::endl;
    std::cout << "\nQ_postApogee:\n"
              << f.Q_postApogee << std::endl;
    std::cout << "\nR:\n"
              << f.R << std::endl;
}

void AltimeterFilterInit(float altitude_m, float vel_z)
{

    f.state << altitude_m, vel_z, 0, 0;
    f.P.setZero();
    f.H << 1, 0, 0, 0,
        0, 0, 0, 0;

    f.Phi << 1, deltaT, 1. / 2. * powf(deltaT, 2), (1. / 3.) * powf(deltaT, 3),
        0, 1, deltaT, (1. / 2.) * powf(deltaT, 2),
        0, 0, 1, deltaT,
        0, 0, 0, 1;
    f.B << 0, 0, 0, 0;

    f.Q_preApogee.setZero();
    f.Q_preApogee.diagonal() << 0.1, 0.1, 0.1, 0.1;

    f.Q_postApogee.setZero();
    f.Q_postApogee.diagonal() << 0.1, 0.1, 0.1, 0.1;

    f.R.setZero();
    f.R.diagonal() << 100, 100;

    f.max_accel = 0;
    f.flight_stage = STAGE_GROUND;
    f.t_apogee = 0;
}

struct AltimeterFilterOutput AltimeterFilterProcess(float altitude_m, float sensed_accel)
{
    // Kalman gain
    auto K = f.P * f.H.transpose() * (f.H * f.P * f.H.transpose() + f.R).inverse();
    // std::cout << "\nK:\n"
    //   << K << std::endl;

    // AltimeterFilterPrint();
    Vector<float, OBSERVATION_LEN> z; // [pressure_altitude, acceleration]
    z(0) = altitude_m;                // Observation
    z(1) = 0;

    // Scale acceleration variance according to current acceleration
    // f.Q(2, 2) = fabs(GetAcceleration()) / 100;

    const float ACCEL_THRESHOLD = 20; // 20 m/s^2

    if (f.max_accel < GetAcceleration())
    {
        f.max_accel = GetAcceleration();
    }

    // Set observation of acceleration to sensed acceleration
    z(1) = sensed_accel;
    // Set acceleration state to relate to acceleration "observation"
    f.H(1, 2) = 1;

    switch (f.flight_stage)
    {
    case STAGE_GROUND:
        // Detect motor burnout
        if (f.max_accel > ACCEL_THRESHOLD && sensed_accel < -3)
        {
            f.flight_stage = STAGE_BURNOUT;
        }
        break;
    case STAGE_BURNOUT:
        // In burnout:
        if (GetVelocity() < 0)
        {
            // TODO: FIRE DA EJECTION CHARGEEEEEE
            f.flight_stage = STAGE_APOGEE;
        }
        break;
    case STAGE_APOGEE:
        // After apogee:
        // While descending, parachute should keep velocity relatively constant
        // Keep "observation" of acceleration at 0
        z(1) = 0;
        // Set acceleration state to relate to acceleration "observation"
        f.H(1, 2) = 1;
        break;
    }

    /* Kalman Filter Update*/
    auto innovation = z - f.H * f.state;
    // Innovation is how much the measured state deviates from the predicted state
    // Which is then used to find the most likely state given the statistical and physical model
    // If we clamp innovation per iteration we limit how much change the KF sees during sensor glitches, 
    // which should make it more resilient to extreme barometer errors
    // Thanks ChatGPT for telling me about clamping innovation
    // auto innovation_clamped = innovation.cwiseMin(1.).cwiseMax(-1.);
        auto state_update = f.state + K * innovation;
    Matrix<float, STATE_LEN, STATE_LEN> I;
    I.setIdentity();
    auto P_update = (I - K * f.H) * f.P;

    f.state = f.Phi * state_update + f.B;
    Matrix<float, 4, 4> &Q = f.Q_preApogee;
    if (f.flight_stage >= STAGE_APOGEE)
    {
        Q = f.Q_postApogee;
    }
    f.P = f.Phi * P_update * f.Phi.transpose() + Q;

    struct AltimeterFilterOutput output = {
        .altitude_m = GetAltitude(),
        .velocity_mps = GetVelocity(),
        .acceleration_mps2 = GetAcceleration(),
        .jerk_mps3 = GetJerk(),
    };
    return output;
}

static float GetAltitude()
{
    return f.state(0);
}

static float GetVelocity()
{
    return f.state(1);
}

static float GetAcceleration()
{
    return f.state(2);
}

static float GetJerk()
{
    return f.state(3);
}

int AltimeterFilterGetFlightStage() {
    return f.flight_stage;
}

void AltimeterFilterSetProcessVariancePreApogee(int i, float val)
{
    f.Q_preApogee.diagonal()(i) = val;
}

void AltimeterFilterSetProcessVariancePostApogee(int i, float val)
{
    f.Q_postApogee.diagonal()(i) = val;
}

void AltimeterFilterSetObservationVariance(int i, float val)
{
    f.R.diagonal()(i) = val;
}

float pressure_mbar_to_ft(float pressure_mbar)
{
    // TODO: Adjustable QNH
    return 145366.45 * (1.0 - powf(pressure_mbar / 1013.25, 0.190284));
}

float m_to_pressure_mbar(float m)
{
    return 0.3048 * powf(-0.00002567 * m + 3.73198405, 5.2553026);
}

