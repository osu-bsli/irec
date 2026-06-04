# Deterministic firmware-in-the-loop: run the real flight firmware as a library under OpenRocket SITL

## STATUS (implementation progress)
- **Stage 0 — dlmopen spike: DONE & verified** (`flight-software-pc/spike/`). Namespace isolation, pthread/TLS, dlclose-reset, no signals.
- **Stage 1 — deterministic host-driven-tick port: DONE & verified.** Preemption off, tickless virtual time, SIGALRM/SIGUSR1/wall-clock removed. 5+ runs byte-identical; real-time pacing opt-in via `FW_REALTIME=1`.
- **Stage 2 — firmware as embeddable SITL `.so`: DONE & verified.** `fw_create/fw_feed_packet/fw_destroy` C ABI; in-memory `Serial` channel (condvar rendezvous, no busy-poll race); real task graph runs over dlmopen; 8/8 runs byte-identical deployment traces. Verified by `sitl-test-harness`.
- **Stage 3 — JNI + Java FULL_SITL: DONE (build-verified).** `AirbrakesMode.FULL_SITL` added; `SitlCreate/SitlFeedPacket/SitlDestroy` native methods dlmopen the firmware `.so` and forward LogPacketV3 frames (reusing the FULL_HITL builder). Java compiles (gradle BUILD SUCCESSFUL); JNI lib compiles, links, exports the symbols. Live JVM→OpenRocket run not exercised here (needs OpenRocket); ASAN on the plugin must be disabled for SITL (documented in CMakeLists). Reuse across runs in one JVM needs Stage 4 teardown.
- Minor latent-bug fixes to firmware (the never-compiled HITL path): `g_airbrake_pct` de-`static`ed (main.cpp), `#include <cstring>` added (testing.cpp).

## Context

`flight-software-pc` already runs the **unmodified Pico flight code** (`flight-software-pico/src/*`)
on the desktop against stubbed Arduino/hardware APIs and the **FreeRTOS V11.3.0 POSIX (pthread)
port** (`flight-software-pc/src/FreeRTOS-port/port.c`).

The real goal (clarified): make OpenRocket's SITL feed simulated flight data into the **actual
firmware task graph** (sensors → GNC → airbrakes → servo), not just the airbrakes algorithm — and
make that reproducible. Today `AirbrakesJniHarness.cpp` calls `AB_Filter_Process` +
`PredictDeploymentPct` **directly**, bypassing FreeRTOS, the sensor drivers, the command/state
machine, the deploy task, and the servo path.

**The protocol already exists.** OpenRocket's `FULL_HITL` mode (`AirbrakesExtension.java:308-331`)
already drives the *real firmware* over serial: it serializes a `LogPacketV3` sensor frame
(timestamp-ms, baro, accel-g, gyro-deg/s, high-G, GPS) via `comPort.writeBytes`, and reads back **1
byte** = commanded deployment %. The firmware consumes it in `acquire_sensor_data` →
`acquire_sensor_data_from_serial(log_p)` then `Serial.write(g_airbrake_pct)`
(`flight-software-pico/src/sensors.cpp:59-66`), gated by `CONFIG_TEST_AIRBRAKES_HITL_FULL`
(`config.h:25`, currently commented out). Crucially, the runtime loop derives `dt` from the
**packet timestamp**, not wall-clock (`main.cpp:458-461,484-486`), so time is already externally
driven.

So SITL = **replace "real Pico over serial" with "firmware compiled as an in-process `.so`," same
LogPacketV3 protocol**, driven deterministically.

### Why the current desktop port is non-deterministic (and incompatible with this goal)

1. **Wall-clock asynchronous tick** (`port.c:452-517`): a free-running pthread `usleep`s and fires
   `SIGALRM` at the current task, preempting at an arbitrary instruction. Equal-priority tasks
   (`configMAX_PRIORITIES-1` everywhere) round-robin via this, so interleaving differs every run.
2. **`SIGALRM`/`SIGUSR1` are process-global.** Loaded into the JVM (or alongside a second instance),
   the firmware's signal handlers collide with the JVM's signal use and with each other. (Note: the
   actual context switch uses pthread condition variables via `event_*`, *not* signals — only the
   tick (SIGALRM) and scheduler-end (SIGUSR1) use signals. That is what makes the fix tractable.)
3. **No clean per-run reset**: FreeRTOS kernel singletons + C++ statics persist across OpenRocket's
   repeated simulations in one JVM → state bleed and nondeterminism.

## Feasibility verdict on the shared-library / separate-namespace idea

**Yes — the instinct is correct and feasible on this box (glibc 2.43).** `dlmopen(LM_ID_NEWLM,
"firmware.so", ...)` loads the firmware into a fresh linker namespace with its **own copy of all
`.data`/`.bss`** (kernel singletons, statics, heap), isolated from the JVM and from other instances.
glibc 2.34+ folds libpthread/libdl into libc, so each namespace gets its own threading state —
threaded code in a namespace works. `dlclose` between OpenRocket runs gives a pristine firmware per
simulation; up to 16 namespaces (`DL_NNS`) can coexist (enough for flight + ground simultaneously).

**The one hard requirement that makes it work — and the same change that delivers determinism:**
replace the `SIGALRM` wall-clock tick with a **host-driven virtual clock**. With no SIGALRM:
- no signal collision with the JVM or between namespaced instances;
- the tick advances only when the host says so → reproducible;
- OpenRocket's per-packet timestamp drives firmware time exactly as `FULL_HITL` already intends.

This supersedes the earlier "keep real-time pacing" decision **for SITL** (OpenRocket paces the
clock). Real-time pacing remains only for the optional standalone two-process desktop demo.

## Approach (staged, spike-first to de-risk the unknowns)

### Stage 0 — Feasibility spike (de-risk before committing)
Tiny standalone `dlmopen` host that loads a minimal FreeRTOS `.so` exposing a host-driven tick, to
prove: (a) globals isolate per namespace; (b) ticks advance with no SIGALRM and no JVM/signal
conflict; (c) pthread/TLS (the port's `pthread_key` in `prvIsFreeRTOSThread`) work inside a
namespace; (d) `dlclose` + reload gives clean state. Disable ASAN for the SITL lib (the plugin
currently builds `-fsanitize=address`, which fights dlmopen+JVM). **Gate: if the spike fails, revisit
before building the full harness.**

### Stage 1 — Deterministic cooperative, host-driven-tick port
In `flight-software-pc/src/FreeRTOS-port/port.c` + `FreeRTOSConfig.h`:
- `configUSE_PREEMPTION 0`, add `configUSE_TIME_SLICING 0` → tasks switch only at their own
  blocking/yield points; no arbitrary preemption. (All app task loops yield via
  `vTaskDelay`/`xTaskDelayUntil`/`delay()`, verified across `main.cpp`, so nothing starves.)
- **Delete** `prvTimerTickHandler`, the `usleep` loop, the `SIGALRM` handler/`sigaction`, and the
  `SIGUSR1` scheduler-end signaling — the wall-clock tick is removed outright, no build flag to
  bring it back. The **only** tick source becomes a host-driven `port_advance_ticks(n)` entry that
  invokes the existing `vPortSystemTickHandler` logic directly (no signal). Keep the
  condition-variable context switch (`event_*`) as-is.
- Real-time pacing, where wanted (the optional standalone two-process desktop demo), is achieved in
  the **host harness** by sleeping between deterministic `port_advance_ticks` calls — pacing lives
  outside the kernel and never reintroduces a non-deterministic in-port clock. Task ordering stays
  deterministic regardless of how the host paces.

### Stage 2 — Firmware as an embeddable shared library with a C ABI
New thin embedding layer (e.g. `flight-software-pc/src/sitl/fw_embed.{h,cpp}`) exposing a stable C
ABI, built with `CONFIG_TEST_AIRBRAKES_HITL_FULL`:
- `fw_create()` → start the FreeRTOS task graph on an internal thread, run to first quiescent point.
- `fw_feed_packet(const uint8_t* logpacket_v3, size_t len) → uint8_t deployment_pct`: push bytes
  into an in-memory channel that **replaces the `Serial` byte source** consumed by
  `acquire_sensor_data_from_serial`, advance the virtual clock to the packet timestamp, run the
  graph to quiescence, and return the byte the firmware would have `Serial.write`-n.
- `fw_destroy()`.
Implement by swapping the `Serial` stub's backing store (`stubs/external/Serial.*`) for an in-memory
ring buffer when embedded, so `Serial.read()`/`Serial.write()` in `sensors.cpp:63-64` need no change.

### Stage 3 — JNI + Java SITL mode
- Add `fw_*` JNI bindings (extend `AirbrakesJniHarness.cpp`; build the firmware sources into the
  existing `airbrakes` SHARED lib in `openrocket-plugin-airbrakes/CMakeLists.txt`, or a sibling
  `firmware` lib). The native side `dlmopen`s the firmware `.so` per simulation for isolation.
- Add an `AirbrakesMode.FULL_SITL` in `AirbrakesExtension.java` that, in `postStep`, builds the same
  `LogPacketV3` it already builds for `FULL_HITL` (lines 302-323) but calls `fw_feed_packet` via JNI
  instead of `comPort.writeBytes`/`readBytes` (321-330). The `LogPacketV3` builder and GPS faking
  are reused unchanged.

### Stage 4 (optional) — Multiple instances in one process
With the host-driven tick + dlmopen proven, run flight + ground firmware `.so`s in one process under
one host clock for a fully deterministic, hardware-free integrated sim. Deferred until Stages 1-3
land.

## Files

- `flight-software-pc/src/FreeRTOSConfig.h` — preemption/time-slicing flags (Stage 1).
- `flight-software-pc/src/FreeRTOS-port/port.c` — host-driven tick replacing SIGALRM loop (Stage 1).
- `flight-software-pc/src/stubs/external/Serial.{h,cpp}` — in-memory byte channel when embedded (Stage 2).
- `flight-software-pc/src/sitl/fw_embed.{h,cpp}` — new C ABI embedding layer (Stage 2).
- `openrocket-plugin-airbrakes/CMakeLists.txt` — build firmware sources into a shared lib (Stage 3).
- `openrocket-plugin-airbrakes/src/main/jni/AirbrakesJniHarness.cpp` + generated JNI header — `fw_*`
  bindings, `dlmopen` loader (Stage 3).
- `openrocket-plugin-airbrakes/src/main/java/space/bsli/AirbrakesExtension.java` (+ `AirbrakesConfig`)
  — `FULL_SITL` mode reusing `LogPacketV3` (Stage 3).
- Reused unchanged: `flight-software-pico/src/*` (firmware), `LogPacketV3.java`,
  `config.h:CONFIG_TEST_AIRBRAKES_HITL_FULL` path. **No firmware logic changes.**

## Verification

1. **Spike (Stage 0):** standalone host prints isolated counters from two namespaced instances and
   advances ticks with no signal; `dlclose`+reload resets state. Run under the JVM too.
2. **Determinism (Stage 1):** run `flight-software-pc` standalone repeatedly; task-switch ordering
   and log sequence identical run-to-run.
3. **SITL end-to-end (Stage 3):** in OpenRocket, run the same flight twice in `FULL_SITL`; the
   commanded-deployment-% trace (`fdtDeploymentPctCommanded`) is bit-identical between runs, and
   matches a `FULL_HITL`-on-hardware run within tolerance. Confirm the full firmware path executes
   (sensor acquire, filter, deploy task, servo write) via firmware logs.
4. **No-hardware regression:** `FULL_SITL` runs with no Pico/serial connected.
