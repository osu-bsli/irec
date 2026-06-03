cmake_minimum_required(VERSION 3.10)
project(pc-testing)

set(EXECUTABLE_NAME gui)

find_package(SDL3 CONFIG REQUIRED)

set(S ../flight-software-pico/)

add_library(airbrakes
    ${S}/src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Filter_Main.cpp
    ${S}/src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ${S}/src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ${S}/src/Airbrakes/AB_Deployment.cpp
    ${S}/src/Airbrakes/MathFunctions.cpp
    ${S}/src/Airbrakes/filter_inputs.cpp

    src/util.cpp
)

target_include_directories(airbrakes PUBLIC
    ${S}/include/
    ${S}/src/
    ${S}/src/Airbrakes
    ${S}/src/Airbrakes/Filters
    ${S}/src/Eigen

    src/pico-stub/

    lib/
    lib/imgui-1.91.9b
    lib/imgui-1.91.9b/backends
    lib/implot-0.16
)

target_compile_options(airbrakes PUBLIC
    $<$<PLATFORM_ID:Windows>:/MP /std:c++20 /RTCsu>
)

add_executable(${EXECUTABLE_NAME}
    src/main.cpp
    src/visualizer.cpp

    lib/imgui-1.91.9b/imgui_demo.cpp
    lib/imgui-1.91.9b/imgui_draw.cpp
    lib/imgui-1.91.9b/imgui_tables.cpp
    lib/imgui-1.91.9b/imgui_widgets.cpp
    lib/imgui-1.91.9b/imgui.cpp
    lib/imgui-1.91.9b/backends/imgui_impl_sdl3.cpp
    lib/imgui-1.91.9b/backends/imgui_impl_sdlrenderer3.cpp
    lib/implot-0.16/implot_demo.cpp
    lib/implot-0.16/implot_items.cpp
    lib/implot-0.16/implot.cpp

    ${CMAKE_SOURCE_DIR}/eigen.natvis
)

target_link_options(${EXECUTABLE_NAME} PRIVATE
  
)

target_link_libraries(${EXECUTABLE_NAME} PUBLIC SDL3::SDL3 airbrakes)

set_property(TARGET ${EXECUTABLE_NAME} PROPERTY CXX_STANDARD 23)

add_executable(drag_coeff_matches_theoretical test/drag_coeff_matches_theoretical.cpp)
add_test(NAME drag_coeff_matches_theoretical COMMAND drag_coeff_matches_theoretical)
target_link_libraries(drag_coeff_matches_theoretical PUBLIC airbrakes)

set_target_properties(${EXECUTABLE_NAME} PROPERTIES 
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
)

add_compile_options(-DEIGEN_INITIALIZE_MATRICES_BY_ZERO)