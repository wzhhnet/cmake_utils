cmake_minimum_required(VERSION 3.16)
project(cmake_test LANGUAGES C CXX)

set(ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
list(APPEND CMAKE_MODULE_PATH ${ROOT_DIR})

include(protobuf)
BUILD_PROTO_TARGET("sample_proto" "${ROOT_DIR}/proto")

include (openssl)
