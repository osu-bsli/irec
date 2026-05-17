#pragma once

#include <assert.h>
#include <math.h>
#include <cmath>

static inline float CHECK_NAN(float x) {
    assert(!isnan(x));
    return x;
}

#define RAD_TO_DEG  57.295779513082320876798154814105

const static inline float SEA_LEVEL_PRESSURE_PA = 101325.0f;
static inline float get_altitude_from_pressure(float pressure_pa)
{
  if (pressure_pa < 0.1f)
    return 0.0f;
  return 44330.0f * (1.0f - std::pow(pressure_pa / SEA_LEVEL_PRESSURE_PA, 1.0f / 5.255f));
}

#ifdef _MSC_VER
  #define PACKED_STRUCT __pragma(pack(push, 1)) struct
  #define END_PACKED_STRUCT __pragma(pack(pop))
#else
  #define PACKED_STRUCT struct __attribute__((packed))
  #define END_PACKED_STRUCT
#endif