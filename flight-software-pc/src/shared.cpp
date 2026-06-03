#include "shared.h"

#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>

void setup();
void loop();

void setup_task(void *pvParameters)
{
    setup();

    vTaskDelete(NULL);
}

void loop_task(void *pvParameters)
{
    while (true)
    {
        loop();
    }
}

void start_arduino_tasks()
{
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

    vTaskStartScheduler();
}