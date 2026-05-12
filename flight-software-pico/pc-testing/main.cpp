#include <config.h>
#include "AB_Deployment.h"

int main()
{
    struct apogeeIC ic = {
        .positionZ = 5000,
        .velocityZ = 500, // around mach 1.5
        .thetaZRad = 80 * (M_PI / 180.0),
        .deploymentAngle = 0.1,
    };

    const float airbrake_pct = PredictDeploymentAngle(&ic, CONFIG_AIRBRAKES_TARGET_APOGEE_METERS);

    printf("======== PredictDeploymentAngle parameters =========\n");
    printf("          positionZ: %f\n", ic.positionZ);
    printf("          velocityZ: %f\n", ic.velocityZ);
    printf("          thetaZRad: %f\n", ic.thetaZRad);
    printf("    deploymentAngle: %f\n", ic.deploymentAngle);
    // println();
    printf("       airbrake_pct: %f\n", airbrake_pct);
    // println();
}