#include <utility.h>

#include "headers/space_bsli_AirbrakesExtension.h"

#include "AB_Deployment.h"
#include "AB_Filter_Main.h"

static AB_Settings settings = AB_Default_Settings();

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SetRocketMass
  (JNIEnv *env, jclass c, float mass_kg) {
    settings.Mass_kg = mass_kg;
}

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SetTargetApogee
  (JNIEnv *env, jclass c, float meters) {
    settings.TargetApogee_m = meters;
}


JNIEXPORT jfloat JNICALL Java_space_bsli_AirbrakesExtension_DragForce
(JNIEnv *env, jclass c, float deployment_pct, float vTotal_mps, float altitude_m) {
    return AB_drag_force(deployment_pct, vTotal_mps, altitude_m, settings);
}

static AB_Filter filter;

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_InitController
(JNIEnv *env, jclass c) {
    AB_Filter_Initialize(filter);
}


JNIEXPORT jfloat JNICALL Java_space_bsli_AirbrakesExtension_RunControllerRawAndGetDeploymentPct
(JNIEnv *env, jclass c,
 jfloat velocityX_mps,
 jfloat velocityY_mps,
 jfloat velocityZ_mps,
 jfloat altitude_m) {
    float velocityHoriz_mps = sqrt(velocityX_mps * velocityX_mps + velocityY_mps * velocityY_mps);
    apogeeIC ic = {
        .altitude_m = altitude_m,
        .velocityZ_mps = velocityZ_mps,
        .thetaZ_rad = (float)(atan2(velocityHoriz_mps, velocityZ_mps)),
        .airbrakeDeployment_pct = 0,
    };

    int itersReqd = 0;
    return PredictDeploymentPct(ic, &itersReqd, settings);
}

JNIEXPORT jfloat JNICALL Java_space_bsli_AirbrakesExtension_RunControllerAndGetDeploymentPct
(JNIEnv *env, jclass c,
 jfloat accelerometerX_mps2,
 jfloat accelerometerY_mps2,
 jfloat accelerometerZ_mps2,
 jfloat accelerometerHgX_mps2,
 jfloat accelerometerHgY_mps2,
 jfloat accelerometerHgZ_mps2,
 jfloat gyroscopeX_radps,
 jfloat gyroscopeY_radps,
 jfloat gyroscopeZ_radps,
 jfloat barometer_m,
 jfloat dt) {
    AB_Filter_Inputs inputs;

    inputs.Accelerometer_mps2.x() = accelerometerX_mps2;
    inputs.Accelerometer_mps2.y() = accelerometerY_mps2;
    inputs.Accelerometer_mps2.z() = accelerometerZ_mps2;
    inputs.AccelerometerHG_mps2.x() = accelerometerHgX_mps2;
    inputs.AccelerometerHG_mps2.y() = accelerometerHgY_mps2;
    inputs.AccelerometerHG_mps2.z() = accelerometerHgZ_mps2;
    inputs.Gyroscope_radps.x() = gyroscopeX_radps;
    inputs.Gyroscope_radps.y() = gyroscopeY_radps;
    inputs.Gyroscope_radps.z() = gyroscopeZ_radps;
    inputs.Magnetometer.setZero();
    inputs.GPS_Position_m.setZero();
    inputs.GPS_Velocity_mps.setZero();
    inputs.Barometer_m = barometer_m;
    inputs.dt = dt;
    inputs.IgnoreBaro = false;

    AB_Filter_Process(filter, inputs, settings);

    float velocityHoriz_mps = sqrt(filter.HorizState.VelocityNorth_mps * filter.HorizState.VelocityNorth_mps +
                    filter.HorizState.VelocityEast_mps * filter.HorizState.VelocityEast_mps);
    apogeeIC ic = {
        .altitude_m = filter.VertState.Altitude_m,
        .velocityZ_mps = filter.VertState.VelocityUp_mps,
        .thetaZ_rad = (float)(atan2(velocityHoriz_mps, filter.VertState.VelocityUp_mps)),
        .airbrakeDeployment_pct = 0,
    };

    int itersReqd = 0;
    return PredictDeploymentPct(ic, &itersReqd, settings);
}
