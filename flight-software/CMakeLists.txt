cmake_minimum_required(VERSION 3.31)

project(flight-software LANGUAGES C CXX VERSION 0.0.1)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

find_package(PkgConfig)
# Order is important here: libgpiodcxx links to libgpiod, so libgpiod has to come AFTER libgpiodcxx
pkg_check_modules(deps IMPORTED_TARGET libgpiodcxx libgpiod)

add_executable(flight-software
    src/main.cpp
)

target_link_libraries(flight-software PRIVATE
    PkgConfig::deps
    -static -static-libstdc++ -static-libgcc
)

install(TARGETS flight-software)
install(DIRECTORY files/etc/ DESTINATION etc)
install(DIRECTORY files/usr/ DESTINATION usr)

set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_CONTACT "Brian Jia <jia.659@buckeyemail.osu.edu>")
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_FILE_NAME "flight-software.deb")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "gpiod")
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_CURRENT_SOURCE_DIR}/dpkg_scripts/postinst;${CMAKE_CURRENT_SOURCE_DIR}/dpkg_scripts/prerm")
include(CPack)