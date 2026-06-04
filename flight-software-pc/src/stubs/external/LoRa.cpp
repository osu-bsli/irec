#include "LoRa.h"

LoRaClass LoRa;

/* Default: no suffix. Overridden by fw_embed.cpp in the SITL build. */
extern "C" __attribute__((weak)) const char *stub_lora_socket_suffix(void)
{
    return "";
}