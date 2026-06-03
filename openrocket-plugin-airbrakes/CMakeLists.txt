cmake_minimum_required(VERSION 3.13)
project(pc-testing)

set(S ${CMAKE_SOURCE_DIR}/../flight-software-pico/)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE})

add_library(airbrakes SHARED
    ${S}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Filter_Main.cpp
    ${S}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ${S}/src/Airbrakes/AB_Deployment.cpp
    ${S}/src/Airbrakes/MathFunctions.cpp
    ${S}/src/Airbrakes/filter_inputs.cpp

    src/main/jni/AirbrakesJniHarness.cpp
)

target_include_directories(airbrakes PUBLIC
    ${S}/include
    ${S}/src
    ${S}/src/Airbrakes
    ${S}/src/Airbrakes/Filters
    ${S}/src/Eigen
    ../airbrakes-gnc-tuning-gui/src/pico-stub
)

target_compile_options(airbrakes PUBLIC 
    $<$<PLATFORM_ID:Windows>:/MP /std:c++20 /DEBUG>
    $<$<PLATFORM_ID:Linux>:-O3 -ggdb -fsanitize=address -Wall -fno-omit-frame-pointer>
)

target_link_options(airbrakes PUBLIC 
    $<$<PLATFORM_ID:Linux>:-O3 -ggdb -fsanitize=address -Wall>
)

# jvm
find_package(Java REQUIRED)
# https://stackoverflow.com/questions/51047978/cmake-could-not-find-jni
set(JAVA_AWT_LIBRARY NotNeeded)
set(JAVA_JVM_LIBRARY NotNeeded)
find_package(JNI REQUIRED)

include_directories(${JNI_INCLUDE_DIRS})

add_compile_options(-DEIGEN_INITIALIZE_MATRICES_BY_ZERO)
