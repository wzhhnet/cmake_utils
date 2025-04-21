###############################################################################
#   FILE NAME   : zlib.cmake
#   CREATE DATE : 2025-04-18
#   MODULE      : CMAKE
#   AUTHOR      : wanch
###############################################################################
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
    cmake_policy(SET CMP0135 NEW)
endif()
include(ExternalProject)

set (ZLIB_VERSION "1.3.1")
set (ZLIB_PREFIX "${CMAKE_BINARY_DIR}/zlib")
#set (ZLIB_URL "${CMAKE_CURRENT_LIST_DIR}/package/zlib-${ZLIB_VERSION}.tar.gz")
set (ZLIB_URL "https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz")
set (ZLIB_URL_HASH "SHA256=9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23")
set (ZLIB_GIT_URL "git@github.com:madler/zlib.git")
set (ZLIB_GIT_TAG "v${ZLIB_VERSION}")
set (ZLIB_INSTALL_DIR ${CMAKE_BINARY_DIR}/zlib_install)
set (ZLIB_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/source/zlib")
set (ZLIB_CMAKE_ARGS
    #TODO: not released for "-DZLIB_BUILD_TESTING=OFF"
    #TODO: not released for "-DZLIB_BUILD_SHARED=OFF"
    "-DZLIB_BUILD_EXAMPLES=OFF"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DCMAKE_INSTALL_PREFIX=${ZLIB_INSTALL_DIR}"
    "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
)

if (ANDROID)
    set (ZLIB_CMAKE_ARGS ${ZLIB_CMAKE_ARGS}
        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
        "-DANDROID_ABI=${CMAKE_ANDROID_ARCH_ABI}"
        "-DANDROID_NDK=${CMAKE_ANDROID_NDK}"
    )
endif (ANDROID)

ExternalProject_Add (zlib
    PREFIX ${ZLIB_PREFIX}
    URL ${ZLIB_URL}
    URL_HASH ${ZLIB_URL_HASH}
    GIT_REPOSITORY "" #TODO:${ZLIB_GIT_URL}
    GIT_TAG "" #TODO:${ZLIB_GIT_TAG}
    GIT_SHALLOW ON
    GIT_PROGRESS ON
    SOURCE_DIR "" #TODO:${ZLIB_SOURCE_DIR}
    CMAKE_ARGS ${ZLIB_CMAKE_ARGS}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND
        ${CMAKE_COMMAND} --build . --target all -- -j8
)

set (ZLIB_INCLUDE_DIR ${ZLIB_INSTALL_DIR}/include CACHE INTERNAL "")
set (ZLIB_LIBRARIES ${ZLIB_SSL_LIBRARY} ${ZLIB_INSTALL_DIR}/lib/libz.a CACHE INTERNAL "")
