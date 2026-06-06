cmake_minimum_required(VERSION 3.10)
project(flight-software-pc)

set(FS ${CMAKE_SOURCE_DIR}/../flight-software-pico/)
set(GS ${CMAKE_SOURCE_DIR}/../ground-computer-pico/)

# The airbrakes GNC relies on zero-initialized Eigen matrices (the OpenRocket
# plugin and tuning-GUI builds both define this). Without it the filter
# covariances start as garbage, which can produce NaNs. Apply to all targets.
add_compile_definitions(EIGEN_INITIALIZE_MATRICES_BY_ZERO)

add_library(shared INTERFACE)

target_sources(shared INTERFACE
    ${CMAKE_SOURCE_DIR}/src/shared.cpp

    ${CMAKE_SOURCE_DIR}/src/FreeRTOS-port/port.c
    ${CMAKE_SOURCE_DIR}/src/FreeRTOS-port/utils/wait_for_event.c

    ${CMAKE_SOURCE_DIR}/src/stubs/external/Servo.cpp
    ${CMAKE_SOURCE_DIR}/src/stubs/external/SD.cpp
    ${CMAKE_SOURCE_DIR}/src/stubs/external/Serial.cpp
    ${CMAKE_SOURCE_DIR}/src/stubs/external/LoRa.cpp

    ${CMAKE_SOURCE_DIR}/src/stubs/internal/gps.cpp
    ${CMAKE_SOURCE_DIR}/src/stubs/internal/hardware.cpp
    ${CMAKE_SOURCE_DIR}/src/stubs/internal/instrumentation.cpp
    ${CMAKE_SOURCE_DIR}/src/stubs/internal/logging.cpp
    ${CMAKE_SOURCE_DIR}/src/stubs/internal/sensors.cpp

    ${CMAKE_SOURCE_DIR}/src/FreeRTOS/FreeRTOS-Kernel/list.c
    ${CMAKE_SOURCE_DIR}/src/FreeRTOS/FreeRTOS-Kernel/queue.c
    ${CMAKE_SOURCE_DIR}/src/FreeRTOS/FreeRTOS-Kernel/tasks.c
    ${CMAKE_SOURCE_DIR}/src/FreeRTOS/FreeRTOS-Kernel/timers.c
    ${CMAKE_SOURCE_DIR}/src/FreeRTOS/FreeRTOS-Kernel/portable/MemMang/heap_3.c

    ${FS}/src/telemetry.cpp
    ${FS}/src/crc16.c
)

target_compile_options(shared INTERFACE
    $<$<PLATFORM_ID:Windows>:/MP /std:c++20 /RTCsu>
    -O3 -Wall -fdiagnostics-color=always
    -fsanitize=address,undefined -ggdb
)

target_link_options(shared INTERFACE
    -fsanitize=address,undefined -ggdb
)

target_compile_definitions(shared INTERFACE
    # FreeRTOS stuff
    projCOVERAGE_TEST=0
    projENABLE_TRACING=0
)

target_include_directories(shared INTERFACE
    src/
    src/FreeRTOS-port/
    src/FreeRTOS-port/utils/
    src/FreeRTOS/FreeRTOS-Kernel/include/
)

add_executable(${PROJECT_NAME}
    ${FS}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ${FS}/src/Airbrakes/Filters/AB_Filter_Main.cpp
    ${FS}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ${FS}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ${FS}/src/Airbrakes/AB_Deployment.cpp
    ${FS}/src/Airbrakes/MathFunctions.cpp
    ${FS}/src/Airbrakes/filter_inputs.cpp

    ${FS}/src/main.cpp

    src/main-flight-software-pc.cpp
)

target_include_directories(${PROJECT_NAME} PUBLIC
    src/stubs/external
    src/stubs/internal

    ${FS}/include/
    ${FS}/src/
    ${FS}/src/Airbrakes
    ${FS}/src/Airbrakes/Filters
    ${FS}/src/Eigen
)

target_link_libraries(${PROJECT_NAME} PUBLIC
    shared
)


add_executable(ground-software-pc
    src/main-ground-software-pc.cpp

    ${GS}/src/main.cpp
)

target_link_libraries(ground-software-pc PUBLIC
    shared
)

target_include_directories(ground-software-pc PUBLIC
    src/stubs/external
    src/stubs/internal

    ${FS}/include/
    ${FS}/src/
    ${FS}/src/Airbrakes
    ${FS}/src/Airbrakes/Filters
    ${FS}/src/Eigen
)


# ============================================================================
# SITL: the flight firmware compiled as an embeddable shared library. The build
# recipe lives in sitl_firmware.cmake so the OpenRocket plugin can build the
# same library from its own CMakeLists without duplicating the source list.
# ============================================================================
include(${CMAKE_CURRENT_LIST_DIR}/sitl_firmware.cmake)
add_flight_firmware_sitl(flight-firmware-sitl)

# SITL verification harness: loads the library via dlmopen and feeds frames.
add_executable(sitl-test-harness src/sitl/sitl_test_harness.cpp)

target_compile_definitions(sitl-test-harness PRIVATE
    projCOVERAGE_TEST=0
    projENABLE_TRACING=0
)

target_include_directories(sitl-test-harness PRIVATE
    ${FS}/include/
    ${FS}/src/
)

target_link_libraries(sitl-test-harness PRIVATE dl pthread)
add_dependencies(sitl-test-harness flight-firmware-sitl)