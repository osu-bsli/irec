#include "AltimeterFilter.h"
#include <cmath>
#include <array>
#include <boost/numeric/odeint.hpp>
#include <boost/array.hpp>

#define AIRBRAKES_STAGE_STOWED 0
#define AIRBRAKES_STAGE_WAITING_TO_DEPLOY 1
#define AIRBRAKES_STAGE_DEPLOYED 2
#define AIRBRAKES_STAGE_RETRACTED_POST_APOGEE 3

int stage = AIRBRAKES_STAGE_STOWED;

float process_variance_pre_apogee[] = {45.397, 0., 3.365, 0.540};
float process_variance_post_apogee[] = {1., 1., 1., 1.};
float observation_variance[] = {89.524, 3.810};

// this is for ADXL375 on peter's original flight computer
const float accel_z_bias = 8.119737;

typedef boost::array<double, 4> state_type;

// this is for asteria II IREC 2025
float rocket_mass_kg = 17.63996;
float drag_model_scale = 9.232;
float target_apogee_ft = 7000;
#define MARGIN_FT 50

float drag_newtons_airbrakes_100(float mach_number)
{
    float x = mach_number;
    return 4.21 - 36.6 * x + 130 * pow(x, 2);
}

float drag_newtons_airbrakes_stowed(float mach_number)
{
    float x = mach_number;
    return 1.39 - 12.7 * x + 56.4 * pow(x, 2);
}

void projectile_motion_rocket_airbrakes_stowed(const state_type &x, state_type &dxdt, double t)
{
    auto speed_of_sound = 343; // TODO: Speed of sound varies with altitude
    float speed = sqrtf(powf(x[2], 2) + powf(x[3], 2));
    auto mach_number = speed / speed_of_sound;
    float drag_newtons = drag_newtons_airbrakes_stowed(mach_number) * drag_model_scale;
    float drag_y_newtons = -drag_newtons * 1;
    dxdt[0] = x[2]; // = v_x
    dxdt[1] = x[3]; // = v_y
    dxdt[2] = 0 / rocket_mass_kg;
    dxdt[3] = -G + drag_y_newtons / rocket_mass_kg;
}

void projectile_motion_rocket_airbrakes_100(const state_type &x, state_type &dxdt, double t)
{
    auto speed_of_sound = 343; // TODO: Speed of sound varies with altitude
    float speed = sqrtf(powf(x[2], 2) + powf(x[3], 2));
    auto mach_number = speed / speed_of_sound;
    float drag_newtons = drag_newtons_airbrakes_100(mach_number) * drag_model_scale;
    float drag_y_newtons = -drag_newtons * 1;
    dxdt[0] = x[2]; // = v_x
    dxdt[1] = x[3]; // = v_y
    dxdt[2] = 0 / rocket_mass_kg;
    dxdt[3] = -G + drag_y_newtons / rocket_mass_kg;
}

float apogee_ft_if_deployed_now(float altitude_m, float velocity_mps)
{
    boost::numeric::odeint::runge_kutta_cash_karp54<state_type> rk;
    state_type x{0, altitude_m, 0, velocity_mps}; // initial condition
    const double dt = 0.1;
    double t_apogee_predictor = 0;
    while (x[3] > 0.0)
    {
        rk.do_step(projectile_motion_rocket_airbrakes_100, x, t_apogee_predictor, dt);
        t_apogee_predictor += dt;
    }

    return x[1] / 0.3048;
}

void airbrakes_init()
{
    AltimeterFilterInit(0., 0.);

    for (int i = 0; i < STATE_LEN; i++)
    {
        AltimeterFilterSetProcessVariancePreApogee(i, process_variance_pre_apogee[i]);
        AltimeterFilterSetProcessVariancePostApogee(i, process_variance_post_apogee[i]);
    }

    for (int i = 0; i < OBSERVATION_LEN; i++)
    {
        AltimeterFilterSetObservationVariance(i, observation_variance[i]);
    }
}

void airbrakes_process(float pressure_mbar, float accel_z_mps2)
{
    auto ft = pressure_mbar_to_ft(pressure_mbar);
    auto m = ft * 0.3048;

    auto earth_rel_accel = (accel_z_mps2 - accel_z_bias) - G;
    auto filter_out = AltimeterFilterProcess(m, earth_rel_accel);
    auto ft_filtered = filter_out.altitude_m / 0.3048;

    // Apogee prediction
    if (AltimeterFilterGetFlightStage() == STAGE_BURNOUT)
    {
        if (stage == AIRBRAKES_STAGE_STOWED)
        {
            stage = AIRBRAKES_STAGE_WAITING_TO_DEPLOY;

            // Serial.println("BURN COMPLETE, READY TO AIRBRAKE!");
        }
    }

    if (AltimeterFilterGetFlightStage() == STAGE_APOGEE)
    {
        if (stage == AIRBRAKES_STAGE_DEPLOYED)
        {
            stage = AIRBRAKES_STAGE_RETRACTED_POST_APOGEE;
            // Serial.println("RETRACT AT APOGEE!");
        }
    }
}

void airbrakes_check_for_deployment()
{
    if (stage == AIRBRAKES_STAGE_WAITING_TO_DEPLOY)
    {
        auto if_now = apogee_ft_if_deployed_now(filter_out.altitude_m, filter_out.velocity_mps);
        if (if_now <= target_apogee_ft + MARGIN_FT && if_now >= target_apogee_ft - MARGIN_FT)
        {
            stage = AIRBRAKES_STAGE_DEPLOYED;
            // Serial.println("AIRBRAKE!!");
        }
    }
}