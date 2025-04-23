###############################################################################
#   FILE NAME   : zstd.cmake
#   CREATE DATE : 2025-04-18
#   MODULE      : CMAKE
#   AUTHOR      : wanch
###############################################################################
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
    cmake_policy(SET CMP0135 NEW)
endif()
#include(ExternalProject)

set (ZSTD_VERSION "1.5.7")
#set (ZSTD_URL "${CMAKE_CURRENT_LIST_DIR}/package/zstd-${ZSTD_VERSION}.tar.gz")
set (ZSTD_URL "https://github.com/facebook/zstd/releases/download/v1.5.7/zstd-1.5.7.tar.gz")
set (ZSTD_URL_HASH "SHA256=eb33e51f49a15e023950cd7825ca74a4a2b43db8354825ac24fc1b7ee09e6fa3")
set (ZSTD_GIT_URL "git@github.com:facebook/zstd.git")
set (ZSTD_GIT_TAG "v${ZSTD_VERSION}")
set (ZSTD_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/source/zstd")

include (FetchContent)

FetchContent_Declare(
    zstd
    #URL ${ZSTD_URL}
    #URL_HASH ${ZSTD_URL_HASH}
    GIT_REPOSITORY ${ZSTD_GIT_URL}
    GIT_TAG ${ZSTD_GIT_TAG}
    GIT_SHALLOW ON
    SOURCE_SUBDIR build/cmake
)

set (BUILD_TESTING OFF)
set (ZSTD_BUILD_SHARED OFF)
set (ZSTD_BUILD_PROGRAMS OFF)
set (ZSTD_LEGACY_SUPPORT OFF)

FetchContent_MakeAvailable(zstd)
#Generated target: libzstd_static
