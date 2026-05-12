cmake_minimum_required(VERSION 3.5)
project(pc-testing)

add_executable(${CMAKE_PROJECT_NAME}
    main.cpp

    ../src/Airbrakes/Filters/AB_Attitude_Filter.cpp
    ../src/Airbrakes/Filters/AB_Filter_Main.cpp
    ../src/Airbrakes/Filters/AB_Horizontal_Filter.cpp
    ../src/Airbrakes/Filters/AB_Vertical_Filter.cpp
    ../src/Airbrakes/AB_Deployment.cpp
    ../src/Airbrakes/MathFunctions.cpp
)

target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE
    -ggdb -static-libgcc -static-libstdc++
)

target_link_options(${CMAKE_PROJECT_NAME} PRIVATE
    -static-libgcc -static-libstdc++
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ../src/
    ../src/Airbrakes
    ../src/Airbrakes/Filters
    ../src/Eigen
)