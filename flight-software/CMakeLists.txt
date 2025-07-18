cmake_minimum_required(VERSION 3.31)

project(flight-software C CXX)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

find_package(PkgConfig)
pkg_check_modules(deps IMPORTED_TARGET libgpiod libgpiodcxx)

add_executable(flight-software
    src/main.cpp
)

target_link_libraries(flight-software PRIVATE
    PkgConfig::deps
)

install(TARGETS flight-software)

set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_CONTACT "Brian Jia <jia.659@buckeyemail.osu.edu>")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libgpiod")
include(CPack)