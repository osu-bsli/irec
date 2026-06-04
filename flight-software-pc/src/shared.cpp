#include "shared.h"

#include <cstdlib>
#include <unistd.h>

#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>

/*
 * Real-time pacing for the standalone desktop demo. The kernel advances virtual
 * time deterministically (see FreeRTOS-port/port.c); this harness-level hook
 * optionally throttles that advance to wall-clock so the demo's serial output
 * and socket link feel live. It only affects pace, never the schedule, so the
 * run stays deterministic. Enabled with FW_REALTIME=1; default is as-fast-as-
 * possible (which is also what keeps runs cheap to diff for determinism tests).
 */
extern "C" TickType_t xPortIdleAdvance(TickType_t xExpectedIdleTime)
{
    static int realtime = -1;
    if (realtime < 0)
        realtime = (getenv("FW_REALTIME") != nullptr) ? 1 : 0;

    if (realtime)
        usleep((useconds_t)xExpectedIdleTime * portTICK_PERIOD_MS * 1000);

    return xExpectedIdleTime;
}

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