###############################################################################
#   FILE NAME   : CMakeLists.txt
#   CREATE DATE : 2025-04-15
#   MODULE      : CMAKE
#   AUTHOR      : wanch
###############################################################################
cmake_minimum_required(VERSION 3.16)
project(cmake_test LANGUAGES C CXX)

set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
list(APPEND CMAKE_MODULE_PATH ${ROOT_DIR})

include (lz4)
include (zlib)
include (openssl)
include (protobuf)
BUILD_PROTO_TARGET("sample_proto" "${ROOT_DIR}/proto")

add_custom_target(build_test DEPENDS lz4 zlib openssl protobuf)
