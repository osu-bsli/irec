#include "AB_Deployment.h"

#include <pico.h>

const float DEPLOYMENT_RATE_PCT_PER_S = 100.0 / 1.7;
const float GROUND_LEVEL_TEMP_CELCIUS = 25;

struct rkDerivs { float dv, dx, dtheta; };

static inline float clamp_cos(float c)
{
    return fabs(c) < 0.01f ? 0.01f : c;
}

static inline float clamp_speed(float v)
{
    return fabs(v) < 0.001f ? 0.001f : v;
}

float AB_drag_force(float deployment_pct, float vTotal_mps, float altitude_m)
{
    float rho = rho_kg_per_m3(altitude_m);
    return 0.5f * rho * drag_coeff(deployment_pct, vTotal_mps, altitude_m, GROUND_LEVEL_TEMP_CELCIUS) * surfaceA(deployment_pct) * (vTotal_mps * vTotal_mps);
}

float AB_drag_accel(float deployment_pct, float vTotal_mps, float altitude_m)
{
    return AB_drag_force(deployment_pct, vTotal_mps, altitude_m) / MASS;
}


// g = gravity(positionZ) pre-computed once per RK4 step; original always uses start-of-step position for gravity.
static inline struct rkDerivs compute_derivs(float g, float pos, float vel, float theta, float dep)
{
    float cos_t  = clamp_cos(cos(theta));
    float v_total = clamp_speed(vel / cos_t);
    float drag   = AB_drag_accel(dep, v_total, pos);
    return { -g - drag * cos_t, vel, g * sin(theta) / v_total };
}

// predict deployment angle, takes in the initial vertical position, vertical velocity, and zenith angle
// uses a binary search to converge on an apogee, attempts to overshoot until it gets within 100m.
float __not_in_flash_func(PredictDeploymentPct)(const struct apogeeIC ic, const float targetApogee, int *out_itersReqd)
{
    *out_itersReqd = 0;

    float low_pct = 0.05;
    float high_pct = 95.0;

    float currentTarget;
    if (ic.altitude_m > 100)
    {
        currentTarget = targetApogee;
    }
    else
    {
        currentTarget = targetApogee + (targetApogee - 100) / 20.0;
    }

    while ((high_pct - low_pct) > 0.01)
    {
        float mid = (low_pct + high_pct) / 2.0;
        float predictedApogee = PredictApogee(ic, mid);

        if (predictedApogee > currentTarget)
            low_pct = mid;  // Need more drag, deploy more
        else
            high_pct = mid; // Need less drag, retract

        (*out_itersReqd)++;
    }

    return (low_pct + high_pct) / 2.0;
}

// gets called by PredictDeploymentPct; integrates trajectory forward using RK4 until apogee.
// TODO: need to account for the slew rate of the airbrakes opening
float __not_in_flash_func(PredictApogee)(const struct apogeeIC ic, const float targetAirbrakeDeployment_pct)
{
    float positionZ  = ic.altitude_m;
    float velocityZ  = ic.velocityZ_mps;
    float thetaZ     = ic.thetaZ_rad;
    float airbrakeDeployment_pct = ic.airbrakeDeployment_pct;
    float dt         = 0.3f;
    int   iter       = 0;

    while (velocityZ > 0.0f && iter < 1000)
    {
        float g = gravity(positionZ);

        struct rkDerivs k1 = compute_derivs(g, positionZ,                 velocityZ,                 thetaZ,                     airbrakeDeployment_pct);
        struct rkDerivs k2 = compute_derivs(g, positionZ + 0.5f*dt*k1.dx, velocityZ + 0.5f*dt*k1.dv, thetaZ + 0.5f*dt*k1.dtheta, airbrakeDeployment_pct);
        struct rkDerivs k3 = compute_derivs(g, positionZ + 0.5f*dt*k2.dx, velocityZ + 0.5f*dt*k2.dv, thetaZ + 0.5f*dt*k2.dtheta, airbrakeDeployment_pct);
        struct rkDerivs k4 = compute_derivs(g, positionZ +      dt*k3.dx, velocityZ +      dt*k3.dv, thetaZ +      dt*k3.dtheta, airbrakeDeployment_pct);

        // these fixed timesteps keep accuracy high, but step size large; could improve with variable-step method
        positionZ += (k1.dx     + 2*k2.dx     + 2*k3.dx     + k4.dx)     * dt / 6.0f;
        velocityZ += (k1.dv     + 2*k2.dv     + 2*k3.dv     + k4.dv)     * dt / 6.0f;
        thetaZ    += (k1.dtheta + 2*k2.dtheta + 2*k3.dtheta + k4.dtheta) * dt / 6.0f;

        bool isDeploying = false;

        if (fabs(airbrakeDeployment_pct - targetAirbrakeDeployment_pct) > 0.01f)
        {
            isDeploying = true;
            float direction;
            if (targetAirbrakeDeployment_pct > airbrakeDeployment_pct)
            {
                direction = 1.0f;
            }
            else
            {
                direction = -1.0f;
            }
            airbrakeDeployment_pct += direction * DEPLOYMENT_RATE_PCT_PER_S * dt;

            if ((direction > 0.0f && airbrakeDeployment_pct > targetAirbrakeDeployment_pct) ||
                (direction < 0.0f && airbrakeDeployment_pct < targetAirbrakeDeployment_pct))
            {
                airbrakeDeployment_pct = targetAirbrakeDeployment_pct;
            }
        }

        if (isDeploying)
        {
            dt = 0.05f;
        }
        else
        {
            if (velocityZ > 343) dt = 0.1f;
            if (velocityZ < 50)  dt = 0.2f;
            else dt = 0.3f;
        }

        iter++;
    }

    return positionZ;
}
