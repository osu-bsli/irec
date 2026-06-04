#pragma once

/*
 * Embeddable SITL interface to the flight firmware.
 *
 * The firmware (flight-software-pico) is compiled into a shared library running
 * its real FreeRTOS task graph under the deterministic port. A host (the SITL
 * test harness, or the OpenRocket JNI bridge) drives it one sensor frame at a
 * time using the same LogPacketV3 protocol the USB-serial HITL path uses:
 * feed a packet, get back the commanded airbrake deployment percentage.
 *
 * For isolation between simulation runs, load this library with
 * dlmopen(LM_ID_NEWLM, ...) once per run so each instance has its own copy of
 * all global state (FreeRTOS kernel, statics, heap).
 */

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Start the firmware. instance_id makes this instance's emulated-radio Unix
 * socket path unique so multiple instances in one process don't collide.
 * Returns after launching the firmware thread; the first fw_feed_packet() call
 * blocks until the firmware has booted and is ready to read a frame.
 */
void fw_create(int instance_id);

/*
 * Feed one LogPacketV3 sensor frame and return the firmware's commanded
 * deployment percentage (0-100). Blocks until the firmware replies.
 */
uint8_t fw_feed_packet(const uint8_t *logpacket_v3, size_t len);

/* Best-effort shutdown. Prefer dlclose-ing the namespace to fully reclaim. */
void fw_destroy(void);

#ifdef __cplusplus
}
#endif
