cmake_minimum_required(VERSION 3.10)
project(flight-software-pc)

set(S ../flight-software-pico/)

add_executable(${PROJECT_NAME}
    ${S}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Filter_Main.cpp
    ${S}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ${S}/src/Airbrakes/AB_Deployment.cpp
    ${S}/src/Airbrakes/MathFunctions.cpp
    ${S}/src/Airbrakes/filter_inputs.cpp

    ${S}/src/main.cpp
    ${S}/src/telemetry.cpp
    ${S}/src/crc16.c

    src/main.cpp

    src/FreeRTOS-port/port.c
    src/FreeRTOS-port/utils/wait_for_event.c
    
    src/stubs/external/Servo.cpp
    src/stubs/external/SD.cpp
    src/stubs/external/LoRa.cpp

    src/stubs/internal/gps.cpp
    src/stubs/internal/hardware.cpp
    src/stubs/internal/instrumentation.cpp
    src/stubs/internal/logging.cpp
    src/stubs/internal/sensors.cpp

    src/FreeRTOS/FreeRTOS-Kernel/list.c
    src/FreeRTOS/FreeRTOS-Kernel/queue.c
    src/FreeRTOS/FreeRTOS-Kernel/tasks.c
    src/FreeRTOS/FreeRTOS-Kernel/timers.c
    src/FreeRTOS/FreeRTOS-Kernel/portable/MemMang/heap_3.c
)

target_include_directories(${PROJECT_NAME} PUBLIC
    src/stubs/external
    src/stubs/internal

    ${S}/include/
    ${S}/src/
    ${S}/src/Airbrakes
    ${S}/src/Airbrakes/Filters
    ${S}/src/Eigen

    src/
    src/FreeRTOS-port/
    src/FreeRTOS-port/utils/
    src/FreeRTOS/FreeRTOS-Kernel/include/
)

target_compile_options(${PROJECT_NAME} PUBLIC
    $<$<PLATFORM_ID:Windows>:/MP /std:c++20 /RTCsu>
    -O3 -Wall -fdiagnostics-color=always
    -fsanitize=address,undefined -ggdb
)

target_link_options(${PROJECT_NAME} PUBLIC
    -fsanitize=address,undefined -ggdb
)

target_compile_definitions(${PROJECT_NAME} PUBLIC
    # FreeRTOS stuff
    projCOVERAGE_TEST=0
    projENABLE_TRACING=0
)

