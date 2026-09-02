#include <utility.h>

#include "headers/space_bsli_AirbrakesExtension.h"

#include "AB_Deployment.h"
#include "AB_Filter_Main.h"

#define _GNU_SOURCE
#include <dlfcn.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

static AB_Settings settings = AB_Default_Settings();

/* ---- FULL_SITL: drive the real firmware running in-process as a library ----
 *
 * The firmware is built alongside this JNI library as
 * libflight-firmware-sitl.so. We load it into a fresh dlmopen namespace so its
 * global state (FreeRTOS kernel, statics) is isolated, then forward sensor
 * frames to its C ABI (fw_create / fw_feed_packet / fw_destroy). The library is
 * located next to this one (found via dladdr), so nothing has to be passed in
 * via environment variables. */
static void *g_fw_handle = nullptr;
static void (*g_fw_create)(int) = nullptr;
static void (*g_fw_set_target)(float) = nullptr;
static void (*g_fw_set_mass)(float) = nullptr;
static void (*g_fw_set_drag_scale)(float) = nullptr;
static uint8_t (*g_fw_feed)(const uint8_t *, size_t) = nullptr;
static void (*g_fw_destroy)(void) = nullptr;

/* Absolute path to libflight-firmware-sitl.so sitting next to this JNI library. */
static std::string firmware_sitl_lib_path() {
    Dl_info info;
    std::string dir = ".";
    if (dladdr((void *) &firmware_sitl_lib_path, &info) && info.dli_fname != nullptr) {
        const char *slash = strrchr(info.dli_fname, '/');
        if (slash != nullptr) dir.assign(info.dli_fname, slash - info.dli_fname);
    }
    return dir + "/libflight-firmware-sitl.so";
}

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SitlCreate
  (JNIEnv *env, jclass c, jint instance_id) {
    std::string path = firmware_sitl_lib_path();

    g_fw_handle = dlmopen(LM_ID_NEWLM, path.c_str(), RTLD_NOW | RTLD_LOCAL);
    if (g_fw_handle == nullptr) {
        fprintf(stderr, "[SITL] dlmopen(%s) failed: %s\n", path.c_str(), dlerror());
        return;
    }

    g_fw_create       = (void (*)(int)) dlsym(g_fw_handle, "fw_create");
    g_fw_set_target   = (void (*)(float)) dlsym(g_fw_handle, "fw_set_target_apogee");
    g_fw_set_mass     = (void (*)(float)) dlsym(g_fw_handle, "fw_set_mass");
    g_fw_set_drag_scale = (void (*)(float)) dlsym(g_fw_handle, "fw_set_drag_scale");
    g_fw_feed         = (uint8_t (*)(const uint8_t *, size_t)) dlsym(g_fw_handle, "fw_feed_packet");
    g_fw_destroy      = (void (*)(void)) dlsym(g_fw_handle, "fw_destroy");
    if (g_fw_create == nullptr || g_fw_set_target == nullptr || g_fw_set_mass == nullptr ||
        g_fw_set_drag_scale == nullptr || g_fw_feed == nullptr || g_fw_destroy == nullptr) {
        fprintf(stderr, "[SITL] dlsym failed: %s\n", dlerror());
        return;
    }

    g_fw_create((int) instance_id);
}

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SitlSetTargetApogee
  (JNIEnv *env, jclass c, jfloat meters) {
    if (g_fw_set_target != nullptr) g_fw_set_target((float) meters);
}

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SitlSetMass
  (JNIEnv *env, jclass c, jfloat kg) {
    if (g_fw_set_mass != nullptr) g_fw_set_mass((float) kg);
}

JNIEXPORT void JNICALL Java_space_bsli_AirbrakesExtension_SitlSetDragScale
  (JNIEnv *env, jclass c, jfloat scale) {
    if (g_fw_set_drag_scale != nullptr) g_fw_set_drag_scale((float) scale);
}

JNIEXPORT jfloat JNICALL Java_space_bsli_AirbrakesExtension_GetTargetApogee
  (JNIEnv *env, jclass c) {
    return settings.TargetApogee_m;
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
    /* fw_destroy() now does a cooperative teardown (stops the firmware's
     * FreeRTOS tasks and scheduler), so by the time it returns no firmware
     * thread is executing code from the dlmopen namespace and we can unload it.
     * Reclaiming the namespace is essential: glibc caps live dlmopen namespaces
     * (DL_NNS == 16), so leaking one per run exhausts them after ~15 runs. */
    if (g_fw_destroy != nullptr) g_fw_destroy();
    if (g_fw_handle != nullptr) dlclose(g_fw_handle);
    g_fw_handle = nullptr;
    g_fw_create = nullptr;
    g_fw_set_target = nullptr;
    g_fw_set_mass = nullptr;
    g_fw_set_drag_scale = nullptr;
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
