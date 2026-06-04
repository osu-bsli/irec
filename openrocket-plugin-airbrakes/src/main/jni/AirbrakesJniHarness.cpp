#include <utility.h>

#include "headers/space_bsli_AirbrakesExtension.h"

#include "AB_Deployment.h"
#include "AB_Filter_Main.h"

#define _GNU_SOURCE
#include <dlfcn.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

static AB_Settings settings = AB_Default_Settings();

/* ---- FULL_SITL: drive the real firmware running in-process as a library ----
 *
 * The firmware is built separately as libflight-firmware-sitl.so (see
 * flight-software-pc). We load it into a fresh dlmopen namespace so its global
 * state (FreeRTOS kernel, statics) is isolated, then forward sensor frames to
 * its C ABI (fw_create / fw_feed_packet / fw_destroy). The path is taken from
 * the FW_SITL_LIB environment variable, defaulting to the bare soname. */
static void *g_fw_handle = nullptr;
static void (*g_fw_create)(int) = nullptr;
static uint8_t (*g_fw_feed)(const uint8_t *, size_t) = nullptr;
static void (*g_fw_destroy)(void) = nullptr;

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SitlCreate
  (JNIEnv *env, jclass c, jint instance_id) {
    const char *path = getenv("FW_SITL_LIB");
    if (path == nullptr) path = "libflight-firmware-sitl.so";

    g_fw_handle = dlmopen(LM_ID_NEWLM, path, RTLD_NOW | RTLD_LOCAL);
    if (g_fw_handle == nullptr) {
        fprintf(stderr, "[SITL] dlmopen(%s) failed: %s\n", path, dlerror());
        return;
    }

    g_fw_create  = (void (*)(int)) dlsym(g_fw_handle, "fw_create");
    g_fw_feed    = (uint8_t (*)(const uint8_t *, size_t)) dlsym(g_fw_handle, "fw_feed_packet");
    g_fw_destroy = (void (*)(void)) dlsym(g_fw_handle, "fw_destroy");
    if (g_fw_create == nullptr || g_fw_feed == nullptr || g_fw_destroy == nullptr) {
        fprintf(stderr, "[SITL] dlsym failed: %s\n", dlerror());
        return;
    }

    g_fw_create((int) instance_id);
}

JNIEXPORT jint JNICALL Java_space_bsli_AirbrakesExtension_SitlFeedPacket
  (JNIEnv *env, jclass c, jbyteArray packet) {
    if (g_fw_feed == nullptr) return 0;

    jsize len = env->GetArrayLength(packet);
    jbyte *bytes = env->GetByteArrayElements(packet, nullptr);
    uint8_t reply = g_fw_feed((const uint8_t *) bytes, (size_t) len);
    env->ReleaseByteArrayElements(packet, bytes, JNI_ABORT);
    return (jint) reply;
}

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SitlDestroy
  (JNIEnv *env, jclass c) {
    if (g_fw_destroy != nullptr) g_fw_destroy();
    /* Not dlclose-ing: the firmware's FreeRTOS threads are still running
     * (clean teardown for reuse across runs is future work). */
    g_fw_handle = nullptr;
    g_fw_create = nullptr;
    g_fw_feed = nullptr;
    g_fw_destroy = nullptr;
}

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

    int itersReqd = 0;
    return PredictDeploymentPct(filter_to_apogee_ic(filter), &itersReqd, settings);
}
