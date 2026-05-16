cmake_minimum_required(VERSION 3.10)
project(pc-testing)

find_package(SDL3 CONFIG REQUIRED)

add_library(airbrakes
    ../src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ../src/Airbrakes/Filters/AB_Filter_Main.cpp
    ../src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ../src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ../src/Airbrakes/AB_Deployment.cpp
    ../src/Airbrakes/MathFunctions.cpp

    src/util.cpp
)

target_include_directories(airbrakes PUBLIC
    ../include/
    ../src/
    ../src/Airbrakes
    ../src/Airbrakes/Filters
    ../src/Eigen

    src/pico-stub/

    lib/
    lib/imgui-1.91.9b
    lib/imgui-1.91.9b/backends
    lib/implot-0.16
)

target_compile_options(airbrakes PUBLIC /std:c++20)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(airbrakes PUBLIC /MT /RTCsu)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # clang_rt.ubsan_standalone is built without debug iterators (IDL=0),
    # incompatible with Debug builds (IDL=2). Only enable for non-Debug configs.
    target_compile_options(airbrakes PUBLIC $<$<NOT:$<CONFIG:Debug>>:-fsanitize=undefined>)
    target_link_options(airbrakes PUBLIC $<$<NOT:$<CONFIG:Debug>>:-fsanitize=undefined>)
endif()

add_executable(${PROJECT_NAME}
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

target_link_options(${PROJECT_NAME} PRIVATE
  
)

target_link_libraries(${PROJECT_NAME} PUBLIC SDL3::SDL3 airbrakes)

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 23)

add_executable(drag_coeff_matches_theoretical test/drag_coeff_matches_theoretical.cpp)
add_test(NAME drag_coeff_matches_theoretical COMMAND drag_coeff_matches_theoretical)
target_link_libraries(drag_coeff_matches_theoretical PUBLIC airbrakes)

set_target_properties(${PROJECT_NAME} PROPERTIES 
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
)

add_compile_options(-DEIGEN_INITIALIZE_MATRICES_BY_ZERO)