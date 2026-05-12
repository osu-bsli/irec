#include "AB_Deployment.h"

//Just initializes the variables in the main function.
void PredictDeploymentAngleInitialize()
{

}

//predict deployment angle, takes in the initial vertical position, vertical velocity, and zentih angle
//uses a binary search to converge on an apogee, attempts to overshoot until it gets within 100m.
float PredictDeploymentAngle(struct apogeeIC *ic, float targetApogee)
{
    float low = 0.05;
    float high = 95.0 * (M_PI / 180);
    float currentAlt = ic->positionZ;

    float currentTarget;
    if (currentAlt > 100) 
    {
        currentTarget = targetApogee;
    }
    else 
    {
        currentTarget = targetApogee + (targetApogee - 100) / 20.0;
    }

    while ((high - low) > 0.0001)
    {
        float mid = (low + high) / 2.0;
        ic->deploymentAngle = mid;
        float predictedApogee = PredictApogee(*ic);

        if (predictedApogee > currentTarget) 
        {
            low = mid; // Need more drag, deploy more
        } 

        else 
        {
            high = mid; // Need less drag, retract
        }
    }

    return (low + high) / 2.0;
}

//gets called by predict deployment angle, uses last deployment angle and initial conditions.
float PredictApogee(const struct apogeeIC ic)
{
    // Unpack [0]=vertical position, [1]=vertical velocity, [2]= zenith angle, [3] deployment angle
    float positionZ = ic.positionZ; 
    float velocityZ = ic.velocityZ; 
    float thetaZ = ic.thetaZRad; 
    float deploymentAngle = ic.deploymentAngle;
    float dt = 0.3;
    int iter = 0;

    // Run until velocity gets below zero, or we hit max iterations.
    while(velocityZ > 0.0 && iter < 1000) {
        
        // k1
        float cos_theta = cos(thetaZ);
        // clamp to prevent dividing by zero
        if (fabs(cos_theta) < 0.01) 
        {
            cos_theta = 0.01;
        } 
        float v_total1 = velocityZ / cos_theta;
        //clamp to prevent velocity from being exactly 0 near apogee, since we divide by it
        if (fabs(v_total1) < 0.001) 
        {
            v_total1 = 0.001;
        } 
        float k1_rho = rho(positionZ);
        float drag1 = (0.5 / MASS) * k1_rho * drag_coeff(deploymentAngle, v_total1, positionZ) * surfaceA(deploymentAngle) * pow(v_total1, 2);
        float k1_v = -1 * gravity(positionZ) - (drag1 * cos_theta);
        float k1_x = velocityZ; 
        float k1_theta = gravity(positionZ) * sin(thetaZ) / v_total1; //same here, can just use total velocity w/ gps

        // k2
        float vk1 = velocityZ + 0.5 * dt * k1_v;
        float posk1 = positionZ + 0.5 * dt * k1_x;
        float thetaK1 = thetaZ + 0.5 * dt * k1_theta;

        float cos_tk1 = cos(thetaK1); 
        if(fabs(cos_tk1) < 0.01) 
        {
            cos_tk1 = 0.01;
        }
        float v_total2 = vk1 / cos_tk1;
        if (fabs(v_total2) < 0.001) 
        {
            v_total2 = 0.001;
        } 
        float k2_rho = rho(posk1);
        float drag2 = (0.5 / MASS) * k2_rho * drag_coeff(deploymentAngle, v_total2, posk1) * surfaceA(deploymentAngle) * pow(v_total2, 2);
        float k2_v = -1 * gravity(positionZ) - (drag2 * cos_tk1);
        float k2_x = vk1; 
        float k2_theta = gravity(positionZ) * sin(thetaK1) / v_total2;

        // k3
        float vk2 = velocityZ + 0.5 * dt * k2_v;
        float posk2 = positionZ + 0.5 * dt * k2_x;
        float thetaK2 = thetaZ + 0.5 * dt * k2_theta;

        float cos_tk2 = cos(thetaK2); 
        if(fabs(cos_tk2) < 0.01) 
        {
            cos_tk2 = 0.01;
        }
        float v_total3 = vk2 / cos_tk2;
        if (fabs(v_total3) < 0.001) 
        {
            v_total3 = 0.001;
        } 
        float k3_rho = rho(posk2);
        float drag3 = (0.5 / MASS) * k3_rho * drag_coeff(deploymentAngle, v_total3, posk2) * surfaceA(deploymentAngle) * pow(v_total3, 2);
        float k3_v = -1 * gravity(positionZ) - (drag3 * cos_tk2);
        float k3_x = vk2; 
        float k3_theta = gravity(positionZ) * sin(thetaK2) / v_total3;

        // k4
        float vk3 = velocityZ + dt * k3_v;
        float posk3 = positionZ + dt * k3_x;
        float thetaK3 = thetaZ + dt * k3_theta;

        float cos_tk3 = cos(thetaK3); 
        if(fabs(cos_tk3) < 0.01) 
        {
            cos_tk3 = 0.01;
        }
        float v_total4 = vk3 / cos_tk3;
        if (fabs(v_total4) < 0.001) 
        {
            v_total4 = 0.001;
        } 
        float k4_rho = rho(posk3);
        float drag4 = (0.5 / MASS) * k4_rho * drag_coeff(deploymentAngle, v_total4, posk3) * surfaceA(deploymentAngle) * pow(v_total4, 2);
        float k4_v = -1 * gravity(positionZ) - (drag4 * cos_tk3);
        float k4_x = vk3; 
        float k4_theta = gravity(positionZ) * sin(thetaK3) / v_total4;

        // Update
        positionZ += (k1_x + 2 * k2_x + 2 * k3_x + k4_x) * dt / 6.0;
        velocityZ += (k1_v + 2 * k2_v + 2 * k3_v + k4_v) * dt / 6.0;
        thetaZ += (k1_theta + 2 * k2_theta + 2 * k3_theta + k4_theta) * dt / 6.0; 

        //these fixed timesteps keep accuracy high, but step size large, possible can improve w/ variable ts method
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

