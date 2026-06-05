# Single source of truth for building the flight firmware as an embeddable SITL
# shared library (libflight-firmware-sitl.so). Both flight-software-pc and the
# OpenRocket plugin include this file and call add_flight_firmware_sitl(<target>)
# so the source list / compile options live in exactly one place.
#
# Captured at include time so the paths work no matter which project includes
# this file.
set(FLIGHT_FIRMWARE_SITL_DIR ${CMAKE_CURRENT_LIST_DIR})

function(add_flight_firmware_sitl TARGET)
    set(PC ${FLIGHT_FIRMWARE_SITL_DIR})          # flight-software-pc/
    set(FW ${FLIGHT_FIRMWARE_SITL_DIR}/../flight-software-pico)

    add_library(${TARGET} SHARED
        ${PC}/src/FreeRTOS-port/port.c
        ${PC}/src/FreeRTOS-port/utils/wait_for_event.c

        ${PC}/src/stubs/external/Servo.cpp
        ${PC}/src/stubs/external/SD.cpp
        ${PC}/src/stubs/external/Serial.cpp
        ${PC}/src/stubs/external/LoRa.cpp
        ${PC}/src/stubs/external/serial_channel.cpp

        ${PC}/src/stubs/internal/gps.cpp
        ${PC}/src/stubs/internal/hardware.cpp
        ${PC}/src/stubs/internal/instrumentation.cpp
        ${PC}/src/stubs/internal/logging.cpp
        # NB: stubs/internal/sensors.cpp is replaced by the SITL sensor adapter
        # (src/sitl/sitl_sensors.cpp), which injects frames over the serial channel.

        ${PC}/src/FreeRTOS/FreeRTOS-Kernel/list.c
        ${PC}/src/FreeRTOS/FreeRTOS-Kernel/queue.c
        ${PC}/src/FreeRTOS/FreeRTOS-Kernel/tasks.c
        ${PC}/src/FreeRTOS/FreeRTOS-Kernel/timers.c
        ${PC}/src/FreeRTOS/FreeRTOS-Kernel/portable/MemMang/heap_3.c

        ${FW}/src/telemetry.cpp
        ${FW}/src/crc16.c
        ${FW}/src/testing/testing.cpp

        ${FW}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
        ${FW}/src/Airbrakes/Filters/AB_Filter_Main.cpp
        ${FW}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
        ${FW}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
        ${FW}/src/Airbrakes/AB_Deployment.cpp
        ${FW}/src/Airbrakes/MathFunctions.cpp
        ${FW}/src/Airbrakes/filter_inputs.cpp

        ${FW}/src/main.cpp

        ${PC}/src/sitl/fw_embed.cpp
        ${PC}/src/sitl/sitl_sensors.cpp
    )

    target_compile_options(${TARGET} PRIVATE
        -O2 -g -Wall -fdiagnostics-color=always
    )

    target_compile_definitions(${TARGET} PRIVATE
        projCOVERAGE_TEST=0
        projENABLE_TRACING=0
        CONFIG_TEST_AIRBRAKES_HITL_FULL
        STUB_SERIAL_IN_MEMORY
        # Record task pthreads (traceTASK_CREATE/DELETE) so fw_destroy can cancel
        # and join every firmware thread, letting dlclose fully reclaim the
        # instance's dlmopen namespace and static TLS.
        FW_SITL_TEARDOWN_TRACE
        # The GNC relies on zero-initialized Eigen matrices (matching the plugin
        # and tuning-GUI builds); without it the filter covariances are garbage.
        EIGEN_INITIALIZE_MATRICES_BY_ZERO
    )

    target_include_directories(${TARGET} PRIVATE
        ${PC}/src/
        ${PC}/src/sitl/
        ${PC}/src/FreeRTOS-port/
        ${PC}/src/FreeRTOS-port/utils/
        ${PC}/src/FreeRTOS/FreeRTOS-Kernel/include/
        ${PC}/src/stubs/external
        ${PC}/src/stubs/internal

        ${FW}/include/
        ${FW}/src/
        ${FW}/src/Airbrakes
        ${FW}/src/Airbrakes/Filters
        ${FW}/src/Eigen
    )

    target_link_libraries(${TARGET} PRIVATE pthread)
endfunction()
