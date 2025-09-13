set(KERNEL_OUTDIR ${CMAKE_CURRENT_BINARY_DIR}/kernel_outdir)
file(MAKE_DIRECTORY ${KERNEL_OUTDIR})

include(FetchContent)
FetchContent_Declare(
    linux
    URL                 https://github.com/raspberrypi/linux/archive/refs/tags/stable_20250702.tar.gz
)
FetchContent_MakeAvailable(linux)

add_custom_target(
    linux ALL
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/build.sh
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/install.sh ${KERNEL_OUTDIR}
    DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/build.sh
        ${CMAKE_CURRENT_SOURCE_DIR}/install.sh
    WORKING_DIRECTORY ${linux_SOURCE_DIR}
    COMMENT "Building kernel with custom configuration..."
    USES_TERMINAL
)

install(DIRECTORY ${KERNEL_OUTDIR}/boot/ DESTINATION usr/share/raspberrypi-linux-bsli/boot/)
install(DIRECTORY ${KERNEL_OUTDIR}/lib/  DESTINATION usr/share/raspberrypi-linux-bsli/lib/)
install(FILES config.txt                 DESTINATION usr/share/raspberrypi-linux-bsli/boot/firmware/)

set(CPACK_GENERATOR "DEB")
set(CPACK_PACKAGE_CONTACT "Brian Jia <jia.659@buckeyemail.osu.edu>")
set(CPACK_PACKAGING_INSTALL_PREFIX "/")
set(CPACK_DEBIAN_FILE_NAME "raspberrypi-linux-bsli.deb")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_CURRENT_SOURCE_DIR}/dpkg_scripts/postinst")
include(CPack)