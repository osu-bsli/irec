cmake_minimum_required(VERSION 3.10)
project(flight-software-pc)

set(S ../flight-software-pico/)

add_library(${PROJECT_NAME}
    ${S}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Filter_Main.cpp
    ${S}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ${S}/src/Airbrakes/AB_Deployment.cpp
    ${S}/src/Airbrakes/MathFunctions.cpp
    ${S}/src/Airbrakes/filter_inputs.cpp

    ${S}/src/main.cpp
    
    src/arduino-stub/Servo.cpp
    src/arduino-stub/SD.cpp
    src/LoRa-stub/LoRa.cpp

    src/FreeRTOS/FreeRTOS-Kernel/list.c
    src/FreeRTOS/FreeRTOS-Kernel/queue.c
    src/FreeRTOS/FreeRTOS-Kernel/tasks.c
    src/FreeRTOS/FreeRTOS-Kernel/timers.c
)

target_include_directories(${PROJECT_NAME} PUBLIC
    src/pico-stub/
    src/arduino-stub/
    src/LoRa-stub/

    ${S}/include/
    ${S}/src/
    ${S}/src/Airbrakes
    ${S}/src/Airbrakes/Filters
    ${S}/src/Eigen

    src/

    src/FreeRTOS/FreeRTOS-Kernel/include
    src/FreeRTOS/FreeRTOS-Kernel/portable/ThirdParty/GCC/Posix
)

target_compile_options(${PROJECT_NAME} PUBLIC
    $<$<PLATFORM_ID:Windows>:/MP /std:c++20 /RTCsu>
    -fdiagnostics-color=always
)

target_compile_definitions(${PROJECT_NAME} PUBLIC
    # FreeRTOS stuff
    projCOVERAGE_TEST=0
    projENABLE_TRACING=0
)

