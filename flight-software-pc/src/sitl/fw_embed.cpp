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
void setup();
void loop();

static char      g_suffix[32] = "";
static pthread_t g_fw_thread;

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

    vTaskStartScheduler(); /* never returns */
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

extern "C" uint8_t fw_feed_packet(const uint8_t *logpacket_v3, size_t len)
{
    serial_channel_host_feed(logpacket_v3, len);
    return serial_channel_host_read_reply();
}

extern "C" void fw_destroy(void)
{
    /* Best-effort: the firmware's FreeRTOS threads are intended to be reclaimed
     * by unloading the dlmopen namespace (or process exit). A full cooperative
     * teardown + thread join is future work (Stage 4). */
}
