/* instrumentation.cpp
 *
 * Sole translation unit that includes <RP2350.h>. Keeping it isolated here
 * prevents the CMSIS hardware register macros (e.g. SPI1, UART0) from
 * conflicting with Arduino peripheral objects of the same name in main.cpp.
 */

#include <RP2350.h>
#include "instrumentation.h"
#include <hardware/platform_defs.h>

void instrumentation_reset(void)
{
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CYCCNT = 0;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
}

uint32_t instrumentation_get_microseconds(void)
{
    return DWT->CYCCNT / SYS_CLK_MHZ;
}
