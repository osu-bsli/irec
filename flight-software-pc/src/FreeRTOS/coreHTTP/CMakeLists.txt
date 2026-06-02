cmake_minimum_required(VERSION 3.15)

project(coreHTTP LANGUAGES C)

# ------------------------------------------------------------------------------
# Includes
# ------------------------------------------------------------------------------

include(${CMAKE_CURRENT_LIST_DIR}/httpFilePaths.cmake)

# ------------------------------------------------------------------------------
# Library targets
# ------------------------------------------------------------------------------

add_library(core_http INTERFACE)

target_sources(core_http INTERFACE ${HTTP_SOURCES})

target_include_directories(core_http
                           INTERFACE ${HTTP_INCLUDE_NO_INTERFACE_PUBLIC_DIRS})

# Separate transport interface library to prevent conflicts with coreMQTT
if(NOT TARGET coremqtt_corehttp_transport_interface)
  add_library(coremqtt_corehttp_transport_interface INTERFACE)

  target_include_directories(coremqtt_corehttp_transport_interface
                             INTERFACE ${HTTP_TRANSPORT_INTERFACE_INCLUDE_DIRS})
endif()

target_link_libraries(core_http INTERFACE coremqtt_corehttp_transport_interface)
