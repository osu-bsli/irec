#include "AB_Deployment.h"

//Just initializes the variables in the main function.
void PredictDeploymentAngleInitialize(AB_Predict_Deployment_Angle_Variables& Variables)
{
    Variables.mid = 0.0;
    Variables.targetApogee = 1970; //input target apogee in m
    Variables.currentTarget = 0;
    Variables.predictedApogee = 0;
}

//predict deployment angle, takes in the initial vertical position, vertical velocity, and zentih angle
//uses a binary search to converge on an apogee, attempts to overshoot until it gets within 100m.
float PredictDeploymentAngle(float* apogeeIC, AB_Predict_Deployment_Angle_Variables& Variables, AB_Predict_Apogee_Variables& AppVariables)
{
    Variables.low = 0.05;
    Variables.high = 95.0;
    Variables.currentAlt = apogeeIC[0];

    if (Variables.currentAlt > 100) 
    {
        Variables.currentTarget = Variables.targetApogee;
    }
    else 
    {
        Variables.currentTarget = Variables.targetApogee + (Variables.targetApogee - 100) / 20.0;
    }

    while ((Variables.high - Variables.low) > 0.0001)
    {
        Variables.mid = (Variables.low + Variables.high) / 2.0;
        apogeeIC[3] = Variables.mid;
        Variables.predictedApogee = PredictApogee(apogeeIC, AppVariables);

        if (Variables.predictedApogee > Variables.currentTarget) 
        {
            Variables.low = Variables.mid; // Need more drag, deploy more
        } 

        else 
        {
            Variables.high = Variables.mid; // Need less drag, retract
        }
    }

    return (Variables.low + Variables.high) / 2.0;
}

//gets called by predict deployment angle, uses last deployment angle and initial conditions.
float PredictApogee(float* apogeeIC, AB_Predict_Apogee_Variables& Variables)
{
    // Unpack [0]=vertical position, [1]=vertical velocity, [2]= zenith angle, [3] deployment angle
    Variables.positionZ = apogeeIC[0]; 
    Variables.velocityZ = apogeeIC[1]; 
    Variables.thetaZ = apogeeIC[2]; 
    Variables.deploymentAngle = apogeeIC[3];
    Variables.dt = 0.3;
    Variables.iter = 0;

    // Run until velocity gets below zero, or we hit max iterations.
    while(Variables.velocityZ > 0.0 && Variables.iter < 1000) {
        
        // k1
        Variables.cos_theta = cos(Variables.thetaZ);
        // clamp to prevent dividing by zero
        if (fabs(Variables.cos_theta) < 0.01) 
        {
            Variables.cos_theta = 0.01;
        } 
        Variables.v_total1 = Variables.velocityZ /Variables.cos_theta;
        //clamp to prevent velocity from being exactly 0 near apogee, since we divide by it
        if (fabs(Variables.v_total1) < 0.001) 
        {
            Variables.v_total1 = 0.001;
        } 
        Variables.k1_rho = rho(Variables.positionZ);
        Variables.drag1 = (0.5 / MASS) * Variables.k1_rho * drag_coeff(Variables.deploymentAngle, Variables.v_total1, Variables.positionZ) * surfaceA(Variables.deploymentAngle) * pow(Variables.v_total1, 2);
        Variables.k1_v = -1 * gravity(Variables.positionZ) - (Variables.drag1 * Variables.cos_theta);
        Variables.k1_x = Variables.velocityZ; 
        Variables.k1_theta = gravity(Variables.positionZ) * sin(Variables.thetaZ) / Variables.v_total1; //same here, can just use total velocity w/ gps

        // k2
        Variables.vk1 = Variables.velocityZ + 0.5 * Variables.dt * Variables.k1_v;
        Variables.posk1 = Variables.positionZ + 0.5 * Variables.dt * Variables.k1_x;
        Variables.thetaK1 = Variables.thetaZ + 0.5 * Variables.dt * Variables.k1_theta;

        Variables.cos_tk1 = cos(Variables.thetaK1); 
        if(fabs(Variables.cos_tk1) < 0.01) 
        {
            Variables.cos_tk1 = 0.01;
        }
        Variables.v_total2 = Variables.vk1 / Variables.cos_tk1;
        if (fabs(Variables.v_total2) < 0.001) 
        {
            Variables.v_total2 = 0.001;
        } 
        Variables.k2_rho = rho(Variables.posk1);
        Variables.drag2 = (0.5 / MASS) * Variables.k2_rho * drag_coeff(Variables.deploymentAngle, Variables.v_total2, Variables.posk1) * surfaceA(Variables.deploymentAngle) * pow(Variables.v_total2, 2);
        Variables.k2_v = -1 * gravity(Variables.positionZ) - (Variables.drag2 * Variables.cos_tk1);
        Variables.k2_x = Variables.vk1; 
        Variables.k2_theta = gravity(Variables.positionZ) * sin(Variables.thetaK1) / Variables.v_total2;

        // k3
        Variables.vk2 = Variables.velocityZ + 0.5 * Variables.dt * Variables.k2_v;
        Variables.posk2 = Variables.positionZ + 0.5 * Variables.dt * Variables.k2_x;
        Variables.thetaK2 = Variables.thetaZ + 0.5 * Variables.dt * Variables.k2_theta;

        Variables.cos_tk2 = cos(Variables.thetaK2); 
        if(fabs(Variables.cos_tk2) < 0.01) 
        {
            Variables.cos_tk2 = 0.01;
        }
        Variables.v_total3 = Variables.vk2 / Variables.cos_tk2;
        if (fabs(Variables.v_total3) < 0.001) 
        {
           Variables. v_total3 = 0.001;
        } 
        Variables.k3_rho = rho(Variables.posk2);
        Variables.drag3 = (0.5 / MASS) * Variables.k3_rho * drag_coeff(Variables.deploymentAngle, Variables.v_total3, Variables.posk2) * surfaceA(Variables.deploymentAngle) * pow(Variables.v_total3, 2);
        Variables.k3_v = -1 * gravity(Variables.positionZ) - (Variables.drag3 * Variables.cos_tk2);
        Variables.k3_x = Variables.vk2; 
        Variables.k3_theta = gravity(Variables.positionZ) * sin(Variables.thetaK2) / Variables.v_total3;

        // k4
        Variables.vk3 = Variables.velocityZ + Variables.dt * Variables.k3_v;
        Variables.posk3 = Variables.positionZ + Variables.dt * Variables.k3_x;
        Variables.thetaK3 = Variables.thetaZ + Variables.dt * Variables.k3_theta;

        Variables.cos_tk3 = cos(Variables.thetaK3); 
        if(fabs(Variables.cos_tk3) < 0.01) 
        {
            Variables.cos_tk3 = 0.01;
        }
        Variables.v_total4 = Variables.vk3 / Variables.cos_tk3;
        if (fabs(Variables.v_total4) < 0.001) 
        {
            Variables.v_total4 = 0.001;
        } 
        Variables.k4_rho = rho(Variables.posk3);
        Variables.drag4 = (0.5 / MASS) * Variables.k4_rho * drag_coeff(Variables.deploymentAngle, Variables.v_total4, Variables.posk3) * surfaceA(Variables.deploymentAngle) * pow(Variables.v_total4, 2);
        Variables.k4_v = -1 * gravity(Variables.positionZ) - (Variables.drag4 * Variables.cos_tk3);
        Variables.k4_x = Variables.vk3; 
        Variables.k4_theta = gravity(Variables.positionZ) * sin(Variables.thetaK3) / Variables.v_total4;

        // Update
        Variables.positionZ += (Variables.k1_x + 2 * Variables.k2_x + 2 * Variables.k3_x + Variables.k4_x) * Variables.dt / 6.0;
        Variables.velocityZ += (Variables.k1_v + 2 * Variables.k2_v + 2 * Variables.k3_v + Variables.k4_v) * Variables.dt / 6.0;
        Variables.thetaZ += (Variables.k1_theta + 2 * Variables.k2_theta + 2 * Variables.k3_theta + Variables.k4_theta) * Variables.dt / 6.0; 

        //these fixed timesteps keep accuracy high, but step size large, possible can improve w/ variable ts method
        if (Variables.velocityZ > 343) 
        {
            Variables.dt = 0.1;
        }

        else if (Variables.velocityZ < 50) 
        {
            Variables.dt = 0.2;
        }

        else 
        {
            Variables.dt = 0.3;
        }
        Variables.iter++;
    }
    
    return Variables.positionZ;
}

