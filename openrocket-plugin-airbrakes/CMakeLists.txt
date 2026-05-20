cmake_minimum_required(VERSION 3.13)
project(pc-testing)

set(FSW_DIR ${CMAKE_SOURCE_DIR}/../flight-software-pico/)

add_library(airbrakes SHARED
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Filter_Main.cpp
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ${FSW_DIR}/src/Airbrakes/AB_Deployment.cpp
    ${FSW_DIR}/src/Airbrakes/MathFunctions.cpp

    src/AirbrakesJniHarness.cpp
)

target_include_directories(airbrakes PUBLIC
    ${FSW_DIR}/include
    ${FSW_DIR}/src
    ${FSW_DIR}/src/Airbrakes
    ${FSW_DIR}/src/Airbrakes/Filters
    ${FSW_DIR}/src/Eigen
    ${FSW_DIR}/pc-testing/src/pico-stub
)

target_compile_options(airbrakes PUBLIC /MP /std:c++20 /DEBUG)

# jvm
find_package(Java REQUIRED)
# https://stackoverflow.com/questions/51047978/cmake-could-not-find-jni
set(JAVA_AWT_LIBRARY NotNeeded)
set(JAVA_JVM_LIBRARY NotNeeded)
find_package(JNI REQUIRED)

include_directories(${JNI_INCLUDE_DIRS})

add_compile_options(-DEIGEN_INITIALIZE_MATRICES_BY_ZERO)
