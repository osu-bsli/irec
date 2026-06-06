/* configASSERT() hook. Defined before the FreeRTOS headers (as the standalone
 * main does) so it keeps C linkage and resolves the C kernel's calls. */
extern "C" void vAssertCalled(const char *const pcFileName, unsigned long ulLine)
{
    (void) pcFileName;
    (void) ulLine;
}

#include "fw_embed.h"

#include <pthread.h>
#include <cstdio>
#include <cstring>

#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>

#include "serial_channel.h"
#include "LoRa.h"
#include "telemetry.h" /* command_packet, RADIO_COMMAND_* */

/* Firmware entry points (flight-software-pico/src/main.cpp), C++ linkage. */
extern QueueHandle_t get_radio_command_rx_queue_handle();
extern void set_target_apogee_m(float meters);
extern void set_rocket_mass_kg(float kg);
extern void set_drag_scale(float scale);
void setup();
void loop();

/* POSIX-port accessor: the pthread backing a FreeRTOS task (see port.c). Lets
 * us cancel+join every firmware thread during teardown. */
extern "C" pthread_t xPortGetTaskPthread(void *pxTask);

static char      g_suffix[32] = "";
static pthread_t g_fw_thread;

/* ---- Cooperative-teardown bookkeeping ----
 * This firmware runs FreeRTOS in cooperative mode (configUSE_PREEMPTION == 0),
 * so a teardown can't be driven from a polling FreeRTOS task (a task blocked in
 * a raw wait stalls the whole scheduler). Instead fw_destroy() drives teardown
 * from the host thread: it ends the scheduler (stopping the tick) and then
 * cancel+joins every firmware task thread, so dlclose can fully reclaim the
 * dlmopen namespace and its static TLS rather than leaking both per run.
 *
 * To know which pthreads to join without enumerating kernel state from a
 * non-FreeRTOS thread, we record each task's pthread as the kernel creates and
 * deletes it (via the traceTASK_CREATE/DELETE hooks; see FreeRTOSConfig.h). All
 * state is per-instance — fw_embed.cpp lives inside the dlmopen namespace. */
#define FW_MAX_TASKS 32
static pthread_t    g_task_pthreads[FW_MAX_TASKS];
static volatile int g_task_pthread_count = 0;

extern "C" void fw_record_task_create(void *tcb)
{
    if (g_task_pthread_count < FW_MAX_TASKS)
        g_task_pthreads[g_task_pthread_count++] = xPortGetTaskPthread(tcb);
}

extern "C" void fw_record_task_delete(void *tcb)
{
    /* A task (e.g. sitl_setup/sitl_inject) deleted itself; the port reclaims its
     * pthread on its own, so drop it from the join list. */
    pthread_t p = xPortGetTaskPthread(tcb);
    for (int i = 0; i < g_task_pthread_count; i++) {
        if (pthread_equal(g_task_pthreads[i], p)) {
            g_task_pthreads[i] = g_task_pthreads[--g_task_pthread_count];
            return;
        }
    }
}

/* Make the emulated-radio socket path unique per instance (see LoRa.h). */
extern "C" const char *stub_lora_socket_suffix(void)
{
    return g_suffix;
}

static void sitl_setup_task(void *pv)
{
    (void) pv;
    setup(); /* creates the runtime/deploy/etc tasks; ends in a keep-alive loop */
    vTaskDelete(NULL);
}

static void sitl_loop_task(void *pv)
{
    (void) pv;
    while (true)
        loop();
}

/*
 * Inject the SWITCH_TO_OPERATIONAL_MODE command the ground station would
 * normally send over the radio, so the firmware leaves pre-operational mode and
 * begins processing injected sensor frames.
 */
static void sitl_inject_switch_task(void *pv)
{
    (void) pv;

    while (!LoRa.has_begun)
        vTaskDelay(100);

    QueueHandle_t q;
    while ((q = get_radio_command_rx_queue_handle()) == NULL)
        vTaskDelay(100);

    command_packet p;
    memset(&p, 0, sizeof(p));
    p.command_byte = RADIO_COMMAND_SWITCH_TO_OPERATIONAL_MODE;
    xQueueSend(q, &p, portMAX_DELAY);

    vTaskDelete(NULL);
}

static void *firmware_thread_main(void *pv)
{
    (void) pv;

    LoRa.setClientOrServer(STUB_LORA_SOCKET_IS_SERVER);

    xTaskCreate(sitl_setup_task, "sitl_setup", 16384, NULL,
                configMAX_PRIORITIES - 1, NULL);
    xTaskCreate(sitl_loop_task, "sitl_loop", 8192, NULL,
                configMAX_PRIORITIES - 1, NULL);
    xTaskCreate(sitl_inject_switch_task, "sitl_inject", 8192, NULL,
                configMAX_PRIORITIES - 1, NULL);

    vTaskStartScheduler(); /* returns when fw_destroy() ends the scheduler */
    return NULL;
}

extern "C" void fw_create(int instance_id)
{
    snprintf(g_suffix, sizeof(g_suffix), "-sitl-%d", instance_id);
    serial_channel_reset();
    pthread_create(&g_fw_thread, NULL, firmware_thread_main, NULL);
}

extern "C" void fw_set_target_apogee(float meters)
{
    set_target_apogee_m(meters);
}

extern "C" void fw_set_mass(float kg)
{
    set_rocket_mass_kg(kg);
}

extern "C" void fw_set_drag_scale(float scale)
{
    set_drag_scale(scale);
}

extern "C" uint8_t fw_feed_packet(const uint8_t *logpacket_v3, size_t len)
{
    serial_channel_host_feed(logpacket_v3, len);
    return serial_channel_host_read_reply();
}

extern "C" void fw_destroy(void)
{
    /* Cooperative teardown, driven entirely from the host thread (the firmware's
     * scheduler is cooperative, so it can't drive its own shutdown reliably).
     *
     * 1. End the scheduler. In the POSIX port this stops and joins the timer-tick
     *    thread (which would otherwise keep running namespace code and crash once
     *    dlclose unmaps it) and signals the scheduler-host thread to return from
     *    vTaskStartScheduler. By now the firmware is quiescent (no more sensor
     *    frames are fed), so every task is blocked at a cancellation point. */
    vTaskEndScheduler();
    pthread_join(g_fw_thread, NULL);

    /* 2. Cancel and join every remaining firmware task thread (recorded via the
     *    traceTASK_CREATE/DELETE hooks). With the scheduler and tick stopped this
     *    is plain pthread work — no FreeRTOS calls. Afterwards no thread is left
     *    executing this instance's namespace code, so dlclose() can fully reclaim
     *    the namespace and its static TLS (otherwise both leak per run and the
     *    process hits glibc's DL_NNS / static-TLS caps after ~15 runs). */
    for (int i = 0; i < g_task_pthread_count; i++) {
        pthread_cancel(g_task_pthreads[i]);
        pthread_join(g_task_pthreads[i], NULL);
    }
    g_task_pthread_count = 0;
}
