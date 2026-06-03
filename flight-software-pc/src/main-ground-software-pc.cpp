extern "C" void vAssertCalled(const char *const pcFileName,
                              unsigned long ulLine)
{
}

#include <cstdio>

#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>

#include "LoRa.h"
#include "telemetry.h"

#include "shared.h"

int main()
{
    LoRa.setClientOrServer(STUB_LORA_SOCKET_IS_CLIENT);

    printf("Starting ground-software-pc...\n");
    
    start_arduino_tasks();
}