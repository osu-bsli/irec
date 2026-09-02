#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Enable the DWT cycle counter and reset it to zero. Call once at the start of
   a timed region. Isolated to instrumentation.cpp to avoid <RP2350.h> register
   name conflicts with Arduino peripheral objects (e.g. SPI1). */
void instrumentation_reset(void);

/* Return microseconds elapsed since the last instrumentation_reset() call. */
uint32_t instrumentation_get_microseconds(void);

#ifdef __cplusplus
}
#endif
