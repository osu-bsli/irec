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
    ../src/
    ../src/Airbrakes
    ../src/Airbrakes/Filters
    ../src/Eigen

    lib/
    lib/imgui-1.91.9b
    lib/imgui-1.91.9b/backends
    lib/implot-0.16
)

target_compile_options(airbrakes PUBLIC
    /MP /fsanitize=address
)

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
)

target_link_options(${PROJECT_NAME} PRIVATE
)

target_link_libraries(${PROJECT_NAME} PUBLIC SDL3::SDL3 airbrakes)

set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 23)

add_executable(drag_coeff_matches_theoretical test/drag_coeff_matches_theoretical.cpp)
add_test(NAME drag_coeff_matches_theoretical COMMAND drag_coeff_matches_theoretical)
target_link_libraries(drag_coeff_matches_theoretical PUBLIC airbrakes)