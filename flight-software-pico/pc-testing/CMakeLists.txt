cmake_minimum_required(VERSION 3.5)
project(pc-testing)

find_package(SDL3 CONFIG REQUIRED)


add_executable(${CMAKE_PROJECT_NAME}
    src/main.cpp
    src/visualizer.cpp

    ../src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ../src/Airbrakes/Filters/AB_Filter_Main.cpp
    ../src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ../src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ../src/Airbrakes/AB_Deployment.cpp
    ../src/Airbrakes/MathFunctions.cpp

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

target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE
    /MP
)

target_link_options(${CMAKE_PROJECT_NAME} PRIVATE

)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    lib/
    lib/imgui-1.91.9b
    lib/imgui-1.91.9b/backends
    lib/implot-0.16

    ../src/
    ../src/Airbrakes
    ../src/Airbrakes/Filters
    ../src/Eigen
)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE SDL3::SDL3)

set_property(TARGET ${CMAKE_PROJECT_NAME} PROPERTY CXX_STANDARD 23)