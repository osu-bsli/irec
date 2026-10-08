# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Avionics monorepo for the Buckeye Space Launch Initiative's IREC rocket (30K SRAD category). The centerpiece is `flight-software-pico`, the SRAD flight computer firmware; everything else either talks to it (ground station), simulates it (SITL/HITL), or tunes its GNC (filter/airbrakes tooling).

## Projects and how they relate

- **`flight-software-pico`** — Flight firmware for a Raspberry Pi Pico 2 (RP2350), Arduino framework (earlephilhower core) + FreeRTOS, built with PlatformIO. This is the source of truth:
  - `src/Airbrakes/` — airbrakes GNC: EKF state estimation (`Filters/AB_Filter_Main.cpp` orchestrating attitude/vertical/horizontal filters) and apogee-prediction deployment control (`AB_Deployment.cpp`). These sources are compiled directly into three other projects (flight-software-pc, airbrakes-gnc-tuning-gui, openrocket-plugin-airbrakes).
  - `include/telemetry.h` — shared wire formats: `log_packet_*` (SD-card flight log) and `telemetry_packet` (LoRa downlink), plus `command_packet` (uplink). CRC16 + magic-string framing. Ground software parses these layouts byte-for-byte, so changing them touches ground-control and the log decoder too.
  - `src/Eigen/` — vendored Eigen; other vendored libs (arduino-LoRa, TinyGPS++, ADS1X15) live in `src/` and `include/`.
  - `src/config.h` — flight configuration (target apogee, LoRa frequencies, accelerometer calibration) and `CONFIG_TEST_*` flags. Enabling any test flag makes the firmware boot into a test loop instead of normal flight behavior (and beeps loudly on boot). They must all be commented out for flight.
  - `tools/decode_flight_log.cpp` — decodes binary `.logv3` SD-card logs to CSV.
- **`flight-software-pc`** — runs the *same* firmware (`main.cpp` included verbatim) on desktop using a FreeRTOS POSIX port plus stubs for Arduino/SD/LoRa/Serial/sensors (`src/stubs/`). Also builds the firmware as an embeddable SITL shared library (`sitl_firmware.cmake`, producing `libflight-firmware-sitl.so`) that the OpenRocket plugin loads via `dlmopen`. `sitl_firmware.cmake` is the single source of truth for that build; both this project and the plugin include it.
- **`openrocket-plugin-airbrakes`** — Java 17/Gradle OpenRocket plugin used for full-loop simulated flights. Its Gradle test task builds the SITL library via CMake and flies the actual firmware inside OpenRocket simulations (`-Dairbrakes.mode=FULL_SITL`, or `CLOSED_LOOP_SIM` to bypass the firmware).
- **`airbrakes-gnc-tuning-gui`** — ImGui/SDL3 desktop visualizer that replays recorded flight logs (`flight-data-logs/`) through the GNC filters for tuning. CMake + vcpkg (preset) or system SDL3.
- **`ground-computer-pico`** — ground-side LoRa radio Pico firmware (PlatformIO), bridges radio ↔ USB serial.
- **`ground-control`** — Rust/egui ground station GUI; consumes telemetry packets over serial from ground-computer-pico.
- **`obsolete/`** — dead code (old ESP32 flight software etc.); don't touch.

## Build & test commands

Everything at once (what CI-style checking looks like):
```bash
./test_all.sh              # builds both firmwares + GUI, runs plugin SITL tests
./test_all_in_docker.sh    # same, inside the repo's Ubuntu Docker image
```

Flight firmware (from `flight-software-pico/`; same for `ground-computer-pico/`):
```bash
pio run                    # build (or: uvx --system-certs platformio run)
pio run -t upload          # flash
pio device monitor         # serial monitor, 921600 baud
```

Desktop firmware build (from `flight-software-pc/`):
```bash
cmake -GNinja -Bbuild && cmake --build build
```

Simulated flight tests (from `openrocket-plugin-airbrakes/`):
```bash
./gradlew_with_asan.sh test --rerun                      # full SITL test suite
./gradlew_with_asan.sh test --tests 'AirbrakesNominalTest' --rerun   # one class
./gradlew run                                            # OpenRocket with plugin GUI
```
Use the `gradlew_with_asan.sh` wrapper, not `./gradlew`, for anything that loads the native library — the firmware/JNI libs are built with ASan and need `LD_PRELOAD`. A Markdown test report lands in `build/reports/tests/test-report.md`.

Tuning GUI (from `airbrakes-gnc-tuning-gui/`):
```bash
cmake -GNinja -Bbuild && cmake --build build   # or cmake --preset=default (vcpkg)
```

Ground station (from `ground-control/`): `cargo run`.

## AI attribution

All AI-generated work must be clearly marked as such and attributed to Claude Code. Append "(Claude Code)" to commit titles for AI-authored commits (see e.g. "Harden flight software robustness (Claude Code)" in history) and keep the Co-Authored-By trailer in commit messages.

## Gotchas

- **`EIGEN_INITIALIZE_MATRICES_BY_ZERO` is load-bearing.** The GNC filters rely on zero-initialized Eigen matrices. All PC builds define it; any new build of the `src/Airbrakes` sources must too, or covariances start as garbage and produce NaNs.
- Plugin tests use `forkEvery = 1` because each FULL_SITL run `dlmopen`s the firmware into a fresh glibc namespace, and namespaces/static-TLS are never reclaimed (~15 per process cap). Don't pile many simulations into one test class.
- The firmware has no `main()`-style mocking seam: HITL/SITL inject sensor data by replacing `sensors.cpp` (see `src/sitl/sitl_sensors.cpp` and the serial-injection path); timestamps come from the injected packets, so the EKF `dt` handling guards against non-monotonic time.
- PlatformIO builds treat warnings seriously (`-Wall -Werror=array-bounds -Werror=stringop-overflow`).
