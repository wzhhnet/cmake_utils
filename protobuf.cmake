###############################################################################
#   FILE NAME   : protobuf.cmake
#   CREATE DATE : 2025-04-15
#   MODULE      : CMAKE
#   AUTHOR      : wanch
###############################################################################
cmake_minimum_required(VERSION 3.16)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.16.0")
    cmake_policy(SET CMP0097 NEW) #GIT_SUBMODULES "" means "no submodules at all"
endif()
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
    cmake_policy(SET CMP0135 NEW)
endif()

include(ExternalProject)
set (PROTOBUF_VERSION "v3.20.1")
set (PROTOBUF_GIT_URL "git@github.com:protocolbuffers/protobuf.git")
set (PROTOBUF_GIT_TAG "${PROTOBUF_VERSION}")
#set (PROTOBUF_URL "${CMAKE_CURRENT_LIST_DIR}/package/protobuf-${PROTOBUF_VERSION}.tar.gz")
set (PROTOBUF_URL "https://github.com/protocolbuffers/protobuf/archive/refs/tags/${PROTOBUF_VERSION}.tar.gz")
set (PROTOBUF_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/source/protobuf")
set (PROTOBUF_HOST_INSTALL_DIR ${CMAKE_BINARY_DIR}/protobuf_host_install)
set (PROTOBUF_TARGET_INSTALL_DIR ${CMAKE_BINARY_DIR}/protobuf_target_install)
set (PROTOBUF_COMMON_ARGS 
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
    "-Dprotobuf_BUILD_TESTS=OFF"
    "-Dprotobuf_BUILD_SHARED_LIBS=OFF"
    "-Dprotobuf_WITH_ZLIB=OFF"
)

# Build protobuf host
ExternalProject_Add (
    protobuf_host
    PREFIX ${CMAKE_BINARY_DIR}/protobuf_host
    URL "" #TODO:${PROTOBUF_URL}
    GIT_REPOSITORY ${PROTOBUF_GIT_URL}
    GIT_TAG ${PROTOBUF_GIT_TAG}
    GIT_SHALLOW ON
    GIT_SUBMODULES ""
    GIT_SUBMODULES_RECURSE OFF
    GIT_PROGRESS ON
    SOURCE_DIR "" #TODO:${PROTOBUF_SOURCE_DIR}
    SOURCE_SUBDIR cmake
    CMAKE_ARGS ${PROTOBUF_COMMON_ARGS}
        "-DCMAKE_INSTALL_PREFIX=${PROTOBUF_HOST_INSTALL_DIR}"
        "-Dprotobuf_BUILD_PROTOC_BINARIES=ON"
    BUILD_COMMAND ${CMAKE_COMMAND} --build . -- -j 8
    BUILD_BYPRODUCTS
        ${PROTOBUF_HOST_INSTALL_DIR}/bin/protoc
)
set (PROTOBUF_TARGETS protobuf_host)

# Cross compile for protobuf target
if (DEFINED CMAKE_TOOLCHAIN_FILE)
    set (PROTOBUF_TARGET_ARGS ${PROTOBUF_COMMON_ARGS}
        "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
        "-DCMAKE_INSTALL_PREFIX=${PROTOBUF_TARGET_INSTALL_DIR}"
        "-Dprotobuf_BUILD_PROTOC_BINARIES=OFF"
    )
    if (ANDROID)
        set (PROTOBUF_TARGET_ARGS ${PROTOBUF_TARGET_ARGS}
            -DANDROID_ABI=${CMAKE_ANDROID_ARCH_ABI}
            -DANDROID_NDK=${CMAKE_ANDROID_NDK}
        )
    endif (ANDROID)
    # Build protobuf target
    ExternalProject_Add (
        protobuf_target
        PREFIX ${CMAKE_BINARY_DIR}/protobuf_target
	URL "" #TODO:${PROTOBUF_URL}
	GIT_REPOSITORY ${PROTOBUF_GIT_URL}
	GIT_TAG ${PROTOBUF_GIT_TAG}
        GIT_SHALLOW ON
        GIT_SUBMODULES ""
        GIT_SUBMODULES_RECURSE OFF
        GIT_PROGRESS ON
	SOURCE_DIR "" #TODO:${PROTOBUF_SOURCE_DIR}
        SOURCE_SUBDIR cmake
        CMAKE_ARGS ${PROTOBUF_TARGET_ARGS}
        BUILD_COMMAND ${CMAKE_COMMAND} --build . -- -j 8
        BUILD_BYPRODUCTS
            ${PROTOBUF_TARGET_INSTALL_DIR}/lib/libprotobuf.a
            ${PROTOBUF_TARGET_INSTALL_DIR}/include/google/protobuf
    )
    list (APPEND PROTOBUF_TARGETS protobuf_target)
else ()
    set (PROTOBUF_TARGET_INSTALL_DIR ${PROTOBUF_HOST_INSTALL_DIR})
endif ()

set (Protobuf_INCLUDE_DIRS ${PROTOBUF_TARGET_INSTALL_DIR}/include
    CACHE INTERNAL "Protobuf include directories")
set (Protobuf_LIBRARIES ${PROTOBUF_TARGET_INSTALL_DIR}/lib/libprotobuf.a
    CACHE INTERNAL "Protobuf libraries")
set (Protobuf_PROTOC_EXECUTABLE ${PROTOBUF_HOST_INSTALL_DIR}/bin/protoc
    CACHE INTERNAL "Protobuf compiler")

###############################################################################
# Automatically generate source files from .proto schema files and create 
# a static library target at build time.
#
# BUILD_PROTO_TARGET(<target-name> <path/to/proto>)
#
# <target-name>
#     Name of the target to be created. This will be a static library
#
# <path/to/proto>
#     Path to the directory containing .proto files include subdirectories
###############################################################################
function (BUILD_PROTO_TARGET TARGET_NAME PROTO_PATH)
    set (OUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}_gen")
    file (MAKE_DIRECTORY ${OUT_PATH})
    file (GLOB_RECURSE PROTOC_PROTO_FILES ${PROTO_PATH}/*.proto)
    if (NOT PROTOC_PROTO_FILES)
        message(FATAL_ERROR "No .proto files found in directory: ${PROTO_PATH}")
    endif()
    list (APPEND PROTOC_PARAMS "--proto_path=${PROTO_PATH}")
    list (APPEND PROTOC_PARAMS "--cpp_out=${OUT_PATH}")
    foreach (EACH_PROTO ${PROTOC_PROTO_FILES})
        file (RELATIVE_PATH REL_PATH ${PROTO_PATH} ${EACH_PROTO})
        get_filename_component (FILE_NAME ${REL_PATH} NAME_WLE)
        get_filename_component (FILE_DIR ${REL_PATH} DIRECTORY)
        set (GEN_HEADER "${OUT_PATH}/${FILE_DIR}/${FILE_NAME}.pb.h")
        set (GEN_SOURCE "${OUT_PATH}/${FILE_DIR}/${FILE_NAME}.pb.cc")
        list (APPEND GEN_SRCS "${GEN_HEADER}" "${GEN_SOURCE}")
    endforeach()
    add_custom_command (
        OUTPUT  ${GEN_SRCS}
        COMMAND ${Protobuf_PROTOC_EXECUTABLE}
        ARGS ${PROTOC_PARAMS} ${PROTOC_PROTO_FILES}
        WORKING_DIRECTORY ${PROTO_PATH}
        DEPENDS ${PROTOC_PROTO_FILES} ${Protobuf_PROTOC_EXECUTABLE}
        COMMENT "Generate Cpp Protobuf Source Files"
    )
    add_compile_options(-fPIC)
    add_library (${TARGET_NAME} STATIC ${GEN_SRCS})
    target_link_libraries (${TARGET_NAME} PUBLIC ${Protobuf_LIBRARIES})
    target_include_directories (${TARGET_NAME} PUBLIC
        ${Protobuf_INCLUDE_DIRS}
        ${OUT_PATH}
    )
    add_dependencies (${TARGET_NAME} ${PROTOBUF_TARGETS})
endfunction ()
