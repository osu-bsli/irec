#pragma once

/*
 * In-memory replacement for the USB-serial byte stream, used when the firmware
 * is built as an embeddable SITL library (STUB_SERIAL_IN_MEMORY). The HITL
 * protocol that normally runs over USB serial (LogPacketV3 in, one
 * deployment-% byte out) is instead carried over two thread-safe byte queues:
 *
 *   host  --(LogPacketV3 bytes)-->  [in]   -->  firmware (Serial.read/available)
 *   host  <--(deployment byte)----  [out]  <--  firmware (Serial.write)
 *
 * The firmware side runs as FreeRTOS tasks; the host side is an ordinary thread
 * (the SITL test harness or the JNI bridge). Both ends are mutex-protected.
 */

#include <cstdint>
#include <cstddef>

#ifdef __cplusplus
extern "C" {
#endif

/* ---- Firmware side (called from FreeRTOS tasks via the Serial stub) ---- */

/* Bytes currently waiting in the host->firmware queue (non-blocking). */
int serial_channel_in_available(void);

/* Pop one host->firmware byte, or -1 if none are queued (non-blocking). */
int serial_channel_in_read(void);

/* Push one firmware->host byte (the deployment-% reply). */
void serial_channel_out_write(uint8_t b);

/* ---- Host side (called from the SITL harness / JNI bridge) ---- */

/* Queue bytes for the firmware to read. */
void serial_channel_host_feed(const uint8_t *data, size_t len);

/* Block until one firmware->host byte is available, then return it. */
uint8_t serial_channel_host_read_reply(void);

/* Reset both queues (e.g. between simulation runs). */
void serial_channel_reset(void);

#ifdef __cplusplus
}
#endif
