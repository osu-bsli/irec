cmake_minimum_required(VERSION 3.13)
project(pc-testing)

set(FSW_DIR ${CMAKE_SOURCE_DIR}/../flight-software-pico/)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE})

add_library(airbrakes SHARED
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Filter_Main.cpp
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ${FSW_DIR}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ${FSW_DIR}/src/Airbrakes/AB_Deployment.cpp
    ${FSW_DIR}/src/Airbrakes/MathFunctions.cpp
    ${FSW_DIR}/src/Airbrakes/filter_inputs.cpp

    src/main/jni/AirbrakesJniHarness.cpp
)

target_include_directories(airbrakes PUBLIC
    ${FSW_DIR}/include
    ${FSW_DIR}/src
    ${FSW_DIR}/src/Airbrakes
    ${FSW_DIR}/src/Airbrakes/Filters
    ${FSW_DIR}/src/Eigen
    ${FSW_DIR}/pc-testing/src/pico-stub
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
