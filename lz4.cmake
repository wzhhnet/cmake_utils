###############################################################################
#   FILE NAME   : lz4.cmake
#   CREATE DATE : 2025-04-18
#   MODULE      : CMAKE
#   AUTHOR      : wanch
###############################################################################
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
    cmake_policy(SET CMP0135 NEW)
endif()
include(ExternalProject)

set (LZ4_VERSION "v1.9.4")
set (LZ4_PREFIX "${CMAKE_BINARY_DIR}/lz4")
set (LZ4_URL "${CMAKE_CURRENT_LIST_DIR}/package/lz4-${LZ4_VERSION}.tar.gz")
#set (LZ4_URL "https://github.com/lz4/lz4/archive/refs/tags/${LZ4_VERSION}.tar.gz")
set (LZ4_GIT_URL "git@github.com:lz4/lz4.git")
set (LZ4_GIT_TAG "${LZ4_VERSION}")
set (LZ4_INSTALL_DIR ${CMAKE_BINARY_DIR}/lz4_install)
set (LZ4_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/source/lz4")
set (LZ4_CMAKE_ARGS
    "-DLZ4_BUILD_CLI=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DCMAKE_INSTALL_PREFIX=${LZ4_INSTALL_DIR}"
    "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
)

if (ANDROID)
    set (LZ4_CMAKE_ARGS ${LZ4_CMAKE_ARGS}
        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
        "-DANDROID_ABI=${CMAKE_ANDROID_ARCH_ABI}"
        "-DANDROID_NDK=${CMAKE_ANDROID_NDK}"
    )
endif (ANDROID)

ExternalProject_Add (lz4
    PREFIX ${LZ4_PREFIX}
    URL "" #TODO:${LZ4_URL}
    GIT_REPOSITORY ${LZ4_GIT_URL}
    GIT_TAG ${LZ4_GIT_TAG}
    GIT_SHALLOW ON
    GIT_PROGRESS ON
    SOURCE_SUBDIR "build/cmake"
    SOURCE_DIR "" #TODO:${LZ4_SOURCE_DIR}
    CMAKE_ARGS ${LZ4_CMAKE_ARGS}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND
        ${CMAKE_COMMAND} --build . --target all -- -j8
)

set (LZ4_INCLUDE_DIR ${LZ4_INSTALL_DIR}/include CACHE INTERNAL "")
set (LZ4_LIBRARIES ${LZ4_SSL_LIBRARY} ${LZ4_INSTALL_DIR}/lib/liblz4.a CACHE INTERNAL "")
