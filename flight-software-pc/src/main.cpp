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

void setup();
void loop();

void setup_task(void *pvParameters)
{
    setup();
}

void loop_task(void *pvParameters)
{
    while (true)
    {
        loop();
    }
}

extern QueueHandle_t get_radio_command_rx_queue_handle();

void feed_fake_data_to_flight_software_task(void *pvParameters)
{
    while (!LoRa.has_begun) {vTaskDelay(100);}

    command_packet p = {
        .command_byte = RADIO_COMMAND_SWITCH_TO_OPERATIONAL_MODE
    };

    printf("[fake data] Sending SWITCH_TO_OPERATIONAL_MODE command...\n");

    xQueueSend(get_radio_command_rx_queue_handle(), &p, NULL);

    vTaskDelete(NULL);
}

int main()
{
    printf("Starting flight-software-pc...\n");

    xTaskCreate(setup_task,               /* The function that implements the task. */
                "setup",                  /* The text name assigned to the task - for debug only as it is not used by the kernel. */
                8192,                     /* The size of the stack to allocate to the task. */
                NULL,                     /* The parameter passed to the task - not used in this simple case. */
                configMAX_PRIORITIES - 1, /* The priority assigned to the task. */
                NULL);                    /* The task handle is not required, so NULL is passed. */

    xTaskCreate(loop_task,                /* The function that implements the task. */
                "loop",                   /* The text name assigned to the task - for debug only as it is not used by the kernel. */
                8192,                     /* The size of the stack to allocate to the task. */
                NULL,                     /* The parameter passed to the task - not used in this simple case. */
                configMAX_PRIORITIES - 1, /* The priority assigned to the task. */
                NULL);                    /* The task handle is not required, so NULL is passed. */

    xTaskCreate(feed_fake_data_to_flight_software_task, /* The function that implements the task. */
                "fake_data",                            /* The text name assigned to the task - for debug only as it is not used by the kernel. */
                8192,                                   /* The size of the stack to allocate to the task. */
                NULL,                                   /* The parameter passed to the task - not used in this simple case. */
                configMAX_PRIORITIES - 1,               /* The priority assigned to the task. */
                NULL);                                  /* The task handle is not required, so NULL is passed. */

    vTaskStartScheduler();
}