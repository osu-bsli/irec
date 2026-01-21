#ifndef ALTIMETER_FILTER_H
#define ALTIMETER_FILTER_H

constexpr int STATE_LEN = 4;
constexpr int OBSERVATION_LEN = 2;
const float G = 9.81f;

#define STAGE_GROUND 0
#define STAGE_BURNOUT 1
#define STAGE_APOGEE 2

struct AltimeterFilterOutput {
    float altitude_m;
    float velocity_mps;
    float acceleration_mps2;
    float jerk_mps3;
};

#ifdef __cplusplus
extern "C"
{
#endif
    float pressure_mbar_to_ft(float mbar);
    float m_to_pressure_mbar(float m);
    void AltimeterFilterInit(float vel_z, float altitude_m);
    struct AltimeterFilterOutput AltimeterFilterProcess(float altitude_m, float accel_z);
    void AltimeterFilterSetProcessVariancePreApogee(int i, float val);
    void AltimeterFilterSetProcessVariancePostApogee(int i, float val);
    void AltimeterFilterSetObservationVariance(int i, float val);
    int AltimeterFilterGetFlightStage();
#ifdef __cplusplus
}
#endif

#endif