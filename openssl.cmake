###############################################################################
#   FILE NAME   : openssl.cmake
#   CREATE DATE : 2025-04-18
#   MODULE      : CMAKE
#   AUTHOR      : wanch
###############################################################################
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.16.0")
    cmake_policy(SET CMP0097 NEW)
endif()
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
    cmake_policy(SET CMP0135 NEW)
endif()
include(ExternalProject)

if (ANDROID)
    set (TOOLCHAIN ${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64)
    set (ANDROID_ENV ANDROID_NDK_HOME=${CMAKE_ANDROID_NDK} PATH=${TOOLCHAIN}/bin:$ENV{PATH})
    if (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "arm64-v8a")
        set (OPENSSL_ARCH android-arm64)
    elseif (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "armeabi-v7a")
        set (OPENSSL_ARCH android-arm)
    else()
        set (OPENSSL_ARCH android-x86_64)
    endif()
else ()
    set (OPENSSL_ARCH linux-x86_64)
endif ()

set (ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}") #TODO
set (PACK_DIR "${ROOT_DIR}/package")
set (OPENSSL_PREFIX "${CMAKE_BINARY_DIR}/openssl")
set (OPENSSL_URL "") #TODO
set (OPENSSL_GIT_URL "git@github.com:openssl/openssl.git")
set (OPENSSL_GIT_TAT "OpenSSL_1_1_1w")
set (OPENSSL_INSTALL_DIR ${CMAKE_BINARY_DIR}/openssl_install)
set (OPENSSL_SOURCE_DIR "") #TODO
set (OPENSSL_CONFIG_ARGS ${OPENSSL_ARCH} no-hw no-asm no-engine no-shared --prefix=${OPENSSL_INSTALL_DIR})

ExternalProject_Add (openssl
    PREFIX ${OPENSSL_PREFIX}
    URL ${OPENSSL_URL}
    GIT_REPOSITORY ${OPENSSL_GIT_URL}
    GIT_TAG ${OPENSSL_GIT_TAG}
    GIT_SHALLOW ON
    GIT_SUBMODULES ""
    GIT_SUBMODULES_RECURSE OFF
    GIT_PROGRESS ON
    SOURCE_DIR ${OPENSSL_SOURCE_DIR}
    CONFIGURE_COMMAND
        ${CMAKE_COMMAND} -E env ${ANDROID_ENV}
        ./Configure ${OPENSSL_CONFIG_ARGS}
    BUILD_IN_SOURCE 1
    BUILD_COMMAND
        ${CMAKE_COMMAND} -E env ${ANDROID_ENV}
        make -j 8
    INSTALL_COMMAND
        ${CMAKE_COMMAND} -E env ${ANDROID_ENV}
        make install_sw
)

set (OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_DIR}/include CACHE INTERNAL "")
set (OPENSSL_SSL_LIBRARY ${OPENSSL_INSTALL_DIR}/lib/libssl.a CACHE INTERNAL "")
set (OPENSSL_CRYPTO_LIBRARY ${OPENSSL_INSTALL_DIR}/lib/libcrypto.a CACHE INTERNAL "")
set (OPENSSL_LIBRARIES ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY} CACHE INTERNAL "")

