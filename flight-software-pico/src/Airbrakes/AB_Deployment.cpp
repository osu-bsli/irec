#include "AB_Deployment.h"

#include <pico.h>

const float GROUND_LEVEL_TEMP_CELCIUS = 25;

// predict deployment angle, takes in the initial vertical position, vertical velocity, and zentih angle
// uses a binary search to converge on an apogee, attempts to overshoot until it gets within 100m.
float __not_in_flash_func(PredictDeploymentPct)(struct apogeeIC ic, const float targetApogee, int *out_itersReqd)
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

    // printf("\033[2J\033[H");

    // TODO: Do we really need 0.0001 precision?
    while ((high_pct - low_pct) > 0.01)
    {
        float mid = (low_pct + high_pct) / 2.0;
        ic.airbrakeDeployment_pct = mid;
        float predictedApogee = PredictApogee(ic);

        // printf("Iter: %d pred: %f m\n", *out_itersReqd, predictedApogee);

        if (predictedApogee > currentTarget)
        {
            low_pct = mid; // Need more drag, deploy more
        }

        else
        {
            high_pct = mid; // Need less drag, retract
        }

        (*out_itersReqd)++;
    }

    return (low_pct + high_pct) / 2.0;
}

// gets called by predict deployment angle, uses last deployment angle and initial conditions.
//  TODO: need to account for the slew rate of the airbrakes opening
float __not_in_flash_func(PredictApogee)(const struct apogeeIC ic)
{
    // Unpack [0]=vertical position, [1]=vertical velocity, [2]= zenith angle, [3] deployment angle
    float positionZ = ic.altitude_m;
    float velocityZ = ic.velocityZ_mps;
    float thetaZ = ic.thetaZ_rad;
    float deploymentAngle = ic.airbrakeDeployment_pct;
    float dt = 0.3;
    int iter = 0;

    // Run until velocity gets below zero, or we hit max iterations.
    while (velocityZ > 0.0 && iter < 1000)
    {
        // k1
        float cos_theta = cos(thetaZ);
        // clamp to prevent dividing by zero
        if (fabs(cos_theta) < 0.01)
        {
            cos_theta = 0.01;
        }
        float v_total1 = velocityZ / cos_theta;
        // clamp to prevent velocity from being exactly 0 near apogee, since we divide by it
        if (fabs(v_total1) < 0.001)
        {
            v_total1 = 0.001;
        }
        float k1_rho = rho_kg_per_m3(positionZ);
        float drag1 = (0.5 / MASS) * k1_rho * drag_coeff(deploymentAngle, v_total1, positionZ, GROUND_LEVEL_TEMP_CELCIUS) * surfaceA(deploymentAngle) * pow(v_total1, 2);
        float k1_v = -1 * gravity(positionZ) - (drag1 * cos_theta);
        float k1_x = velocityZ;
        float k1_theta = gravity(positionZ) * sin(thetaZ) / v_total1; // same here, can just use total velocity w/ gps

        // k2
        float vk1 = velocityZ + 0.5 * dt * k1_v;
        float posk1 = positionZ + 0.5 * dt * k1_x;
        float thetaK1 = thetaZ + 0.5 * dt * k1_theta;

        float cos_tk1 = cos(thetaK1);
        if (fabs(cos_tk1) < 0.01)
        {
            cos_tk1 = 0.01;
        }
        float v_total2 = vk1 / cos_tk1;
        if (fabs(v_total2) < 0.001)
        {
            v_total2 = 0.001;
        }
        float k2_rho = rho_kg_per_m3(posk1);
        float drag2 = (0.5 / MASS) * k2_rho * drag_coeff(deploymentAngle, v_total2, posk1, GROUND_LEVEL_TEMP_CELCIUS) * surfaceA(deploymentAngle) * pow(v_total2, 2);
        float k2_v = -1 * gravity(positionZ) - (drag2 * cos_tk1);
        float k2_x = vk1;
        float k2_theta = gravity(positionZ) * sin(thetaK1) / v_total2;

        // k3
        float vk2 = velocityZ + 0.5 * dt * k2_v;
        float posk2 = positionZ + 0.5 * dt * k2_x;
        float thetaK2 = thetaZ + 0.5 * dt * k2_theta;

        float cos_tk2 = cos(thetaK2);
        if (fabs(cos_tk2) < 0.01)
        {
            cos_tk2 = 0.01;
        }
        float v_total3 = vk2 / cos_tk2;
        if (fabs(v_total3) < 0.001)
        {
            v_total3 = 0.001;
        }
        float k3_rho = rho_kg_per_m3(posk2);
        float drag3 = (0.5 / MASS) * k3_rho * drag_coeff(deploymentAngle, v_total3, posk2, GROUND_LEVEL_TEMP_CELCIUS) * surfaceA(deploymentAngle) * pow(v_total3, 2);
        float k3_v = -1 * gravity(positionZ) - (drag3 * cos_tk2);
        float k3_x = vk2;
        float k3_theta = gravity(positionZ) * sin(thetaK2) / v_total3;

        // k4
        float vk3 = velocityZ + dt * k3_v;
        float posk3 = positionZ + dt * k3_x;
        float thetaK3 = thetaZ + dt * k3_theta;

        float cos_tk3 = cos(thetaK3);
        if (fabs(cos_tk3) < 0.01)
        {
            cos_tk3 = 0.01;
        }
        float v_total4 = vk3 / cos_tk3;
        if (fabs(v_total4) < 0.001)
        {
            v_total4 = 0.001;
        }
        float k4_rho = rho_kg_per_m3(posk3);
        float drag4 = (0.5 / MASS) * k4_rho * drag_coeff(deploymentAngle, v_total4, posk3, GROUND_LEVEL_TEMP_CELCIUS) * surfaceA(deploymentAngle) * pow(v_total4, 2);
        float k4_v = -1 * gravity(positionZ) - (drag4 * cos_tk3);
        float k4_x = vk3;
        float k4_theta = gravity(positionZ) * sin(thetaK3) / v_total4;

        // Update
        positionZ += (k1_x + 2 * k2_x + 2 * k3_x + k4_x) * dt / 6.0;
        velocityZ += (k1_v + 2 * k2_v + 2 * k3_v + k4_v) * dt / 6.0;
        thetaZ += (k1_theta + 2 * k2_theta + 2 * k3_theta + k4_theta) * dt / 6.0;

        // these fixed timesteps keep accuracy high, but step size large, possible can improve w/ variable ts method
        if (velocityZ > 343)
        {
            dt = 0.1;
        }
        else if (velocityZ < 50)
        {
            dt = 0.2;
        }
        else
        {
            dt = 0.3;
        }
        iter++;
    }

    return positionZ;
}
